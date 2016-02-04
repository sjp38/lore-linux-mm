Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 968554403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 03:44:04 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id cw1so26897077lbb.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 00:44:04 -0800 (PST)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id 203si6645985lfe.79.2016.02.04.00.44.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 00:44:03 -0800 (PST)
Received: by mail-lf0-x22b.google.com with SMTP id m1so31833315lfg.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 00:44:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALYGNiOksSkSzJWz3JPPozfeAaHPWOQZFgDzSr-MnR9zVBTncw@mail.gmail.com>
References: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
	<1453929472-25566-2-git-send-email-matthew.r.wilcox@intel.com>
	<CALYGNiOksSkSzJWz3JPPozfeAaHPWOQZFgDzSr-MnR9zVBTncw@mail.gmail.com>
Date: Thu, 4 Feb 2016 11:44:02 +0300
Message-ID: <CALYGNiPkrB4JauWkTNsqxH++iiCGtaRWQGFMW2BU7VDfz-rq=A@mail.gmail.com>
Subject: Re: [PATCH 1/5] radix-tree: Fix race in gang lookup
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: multipart/mixed; boundary=001a113dc134935644052aedbcc2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ohad Ben-Cohen <ohad@wizery.com>, Matthew Wilcox <willy@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Stable <stable@vger.kernel.org>

--001a113dc134935644052aedbcc2
Content-Type: text/plain; charset=UTF-8

On Thu, Feb 4, 2016 at 12:37 AM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> On Thu, Jan 28, 2016 at 12:17 AM, Matthew Wilcox
> <matthew.r.wilcox@intel.com> wrote:
>> From: Matthew Wilcox <willy@linux.intel.com>
>>
>> If the indirect_ptr bit is set on a slot, that indicates we need to
>> redo the lookup.  Introduce a new function radix_tree_iter_retry()
>> which forces the loop to retry the lookup by setting 'slot' to NULL and
>> turning the iterator back to point at the problematic entry.
>>
>> This is a pretty rare problem to hit at the moment; the lookup has to
>> race with a grow of the radix tree from a height of 0.  The consequences
>> of hitting this race are that gang lookup could return a pointer to a
>> radix_tree_node instead of a pointer to whatever the user had inserted
>> in the tree.
>>
>> Fixes: cebbd29e1c2f ("radix-tree: rewrite gang lookup using iterator")
>> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
>> Cc: stable@vger.kernel.org
>> ---
>>  include/linux/radix-tree.h | 16 ++++++++++++++++
>>  lib/radix-tree.c           | 12 ++++++++++--
>>  2 files changed, 26 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
>> index f9a3da5bf892..db0ed595749b 100644
>> --- a/include/linux/radix-tree.h
>> +++ b/include/linux/radix-tree.h
>> @@ -387,6 +387,22 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
>>                              struct radix_tree_iter *iter, unsigned flags);
>>
>>  /**
>> + * radix_tree_iter_retry - retry this chunk of the iteration
>> + * @iter:      iterator state
>> + *
>> + * If we iterate over a tree protected only by the RCU lock, a race
>> + * against deletion or creation may result in seeing a slot for which
>> + * radix_tree_deref_retry() returns true.  If so, call this function
>> + * and continue the iteration.
>> + */
>> +static inline __must_check
>> +void **radix_tree_iter_retry(struct radix_tree_iter *iter)
>> +{
>> +       iter->next_index = iter->index;
>> +       return NULL;
>> +}
>> +
>> +/**
>>   * radix_tree_chunk_size - get current chunk size
>>   *
>>   * @iter:      pointer to radix tree iterator
>> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
>> index a25f635dcc56..65422ac17114 100644
>> --- a/lib/radix-tree.c
>> +++ b/lib/radix-tree.c
>> @@ -1105,9 +1105,13 @@ radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
>>                 return 0;
>>
>>         radix_tree_for_each_slot(slot, root, &iter, first_index) {
>> -               results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
>> +               results[ret] = rcu_dereference_raw(*slot);
>>                 if (!results[ret])
>>                         continue;
>> +               if (radix_tree_is_indirect_ptr(results[ret])) {
>> +                       slot = radix_tree_iter_retry(&iter);
>> +                       continue;
>> +               }
>>                 if (++ret == max_items)
>>                         break;
>>         }
>
> Looks like your fix doesn't work.
>
> After radix_tree_iter_retry: radix_tree_for_each_slot will call
> radix_tree_next_slot which isn't safe to call for NULL slot.
>
> #define radix_tree_for_each_slot(slot, root, iter, start) \
> for (slot = radix_tree_iter_init(iter, start) ; \
>     slot || (slot = radix_tree_next_chunk(root, iter, 0)) ; \
>     slot = radix_tree_next_slot(slot, iter, 0))
>
> tagged iterator works becase restart happens only at root - tags
> filled with single bit.
>
> quick (untested) fix for that
>
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -457,9 +457,9 @@ radix_tree_next_slot(void **slot, struct
> radix_tree_iter *iter, unsigned flags)
>                         return slot + offset + 1;
>                 }
>         } else {
> -               unsigned size = radix_tree_chunk_size(iter) - 1;
> +               int size = radix_tree_chunk_size(iter) - 1;
>
> -               while (size--) {
> +               while (size-- > 0) {
>                         slot++;
>                         iter->index++;
>                         if (likely(*slot))
>
>

Yep. Kernel crashes. Test in attachment.

fix: https://lkml.kernel.org/r/145457528789.31321.4441662473067711123.stgit@zurg

>> @@ -1184,9 +1188,13 @@ radix_tree_gang_lookup_tag(struct radix_tree_root *root, void **results,
>>                 return 0;
>>
>>         radix_tree_for_each_tagged(slot, root, &iter, first_index, tag) {
>> -               results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
>> +               results[ret] = rcu_dereference_raw(*slot);
>>                 if (!results[ret])
>>                         continue;
>> +               if (radix_tree_is_indirect_ptr(results[ret])) {
>> +                       slot = radix_tree_iter_retry(&iter);
>> +                       continue;
>> +               }
>>                 if (++ret == max_items)
>>                         break;
>>         }
>> --
>> 2.7.0.rc3
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--001a113dc134935644052aedbcc2
Content-Type: application/octet-stream;
	name=radix-tree-test-radix_tree_iter_retry
Content-Disposition: attachment;
	filename=radix-tree-test-radix_tree_iter_retry
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ik80mj2u0

cmFkaXgtdHJlZTogdGVzdCByYWRpeF90cmVlX2l0ZXJfcmV0cnkKCkZyb206IEtvbnN0YW50aW4g
S2hsZWJuaWtvdiA8a29jdDlpQGdtYWlsLmNvbT4KClNpZ25lZC1vZmYtYnk6IEtvbnN0YW50aW4g
S2hsZWJuaWtvdiA8a29jdDlpQGdtYWlsLmNvbT4KLS0tCiBsaWIvcmFkaXgtdHJlZS5jIHwgICA2
MiArKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysK
IDEgZmlsZSBjaGFuZ2VkLCA2MiBpbnNlcnRpb25zKCspCgpkaWZmIC0tZ2l0IGEvbGliL3JhZGl4
LXRyZWUuYyBiL2xpYi9yYWRpeC10cmVlLmMKaW5kZXggNmI3OWU5MDI2ZTI0Li5mNDg5MzM0Yjlj
YjcgMTAwNjQ0Ci0tLSBhL2xpYi9yYWRpeC10cmVlLmMKKysrIGIvbGliL3JhZGl4LXRyZWUuYwpA
QCAtMTQ5MSw2ICsxNDkxLDY2IEBAIHN0YXRpYyBpbnQgcmFkaXhfdHJlZV9jYWxsYmFjayhzdHJ1
Y3Qgbm90aWZpZXJfYmxvY2sgKm5mYiwKICAgICAgICByZXR1cm4gTk9USUZZX09LOwogfQogCitz
dGF0aWMgdm9pZCB0ZXN0X2l0ZXJfcmV0cnkodm9pZCkKK3sKKwlSQURJWF9UUkVFKHJvb3QsIEdG
UF9LRVJORUwpOworCXZvaWQgKnB0ciA9ICh2b2lkICopNHVsOworCXN0cnVjdCByYWRpeF90cmVl
X2l0ZXIgaXRlcjsKKwl2b2lkICoqc2xvdDsKKwlib29sIGZpcnN0OworCisJcmFkaXhfdHJlZV9p
bnNlcnQoJnJvb3QsIDAsIHB0cik7CisJcmFkaXhfdHJlZV90YWdfc2V0KCZyb290LCAwLCAwKTsK
KworCWZpcnN0ID0gdHJ1ZTsKKwlyYWRpeF90cmVlX2Zvcl9lYWNoX3RhZ2dlZChzbG90LCAmcm9v
dCwgJml0ZXIsIDAsIDApIHsKKwkJcHJpbnRrKCJ0YWdnZWQgJWxkICVwXG4iLCBpdGVyLmluZGV4
LCAqc2xvdCk7CisJCWlmIChmaXJzdCkgeworCQkJcmFkaXhfdHJlZV9pbnNlcnQoJnJvb3QsIDEs
IHB0cik7CisJCQlyYWRpeF90cmVlX3RhZ19zZXQoJnJvb3QsIDEsIDApOworCQkJZmlyc3QgPSBm
YWxzZTsKKwkJfQorCQlpZiAocmFkaXhfdHJlZV9kZXJlZl9yZXRyeSgqc2xvdCkpIHsKKwkJCXBy
aW50aygicmV0cnkgJWxkXG4iLCBpdGVyLmluZGV4KTsKKwkJCXNsb3QgPSByYWRpeF90cmVlX2l0
ZXJfcmV0cnkoJml0ZXIpOworCQkJY29udGludWU7CisJCX0KKwl9CisJcmFkaXhfdHJlZV9kZWxl
dGUoJnJvb3QsIDEpOworCisJZmlyc3QgPSB0cnVlOworCXJhZGl4X3RyZWVfZm9yX2VhY2hfc2xv
dChzbG90LCAmcm9vdCwgJml0ZXIsIDApIHsKKwkJcHJpbnRrKCJzbG90ICVsZCAlcFxuIiwgaXRl
ci5pbmRleCwgKnNsb3QpOworCQlpZiAoZmlyc3QpIHsKKwkJCXJhZGl4X3RyZWVfaW5zZXJ0KCZy
b290LCAxLCBwdHIpOworCQkJZmlyc3QgPSBmYWxzZTsKKwkJfQorCQlpZiAocmFkaXhfdHJlZV9k
ZXJlZl9yZXRyeSgqc2xvdCkpIHsKKwkJCXByaW50aygicmV0cnkgJWxkXG4iLCBpdGVyLmluZGV4
KTsKKwkJCXNsb3QgPSByYWRpeF90cmVlX2l0ZXJfcmV0cnkoJml0ZXIpOworCQkJY29udGludWU7
CisJCX0KKwl9CisJcmFkaXhfdHJlZV9kZWxldGUoJnJvb3QsIDEpOworCisJZmlyc3QgPSB0cnVl
OworCXJhZGl4X3RyZWVfZm9yX2VhY2hfY29udGlnKHNsb3QsICZyb290LCAmaXRlciwgMCkgewor
CQlwcmludGsoImNvbnRpZyAlbGQgJXBcbiIsIGl0ZXIuaW5kZXgsICpzbG90KTsKKwkJaWYgKGZp
cnN0KSB7CisJCQlyYWRpeF90cmVlX2luc2VydCgmcm9vdCwgMSwgcHRyKTsKKwkJCWZpcnN0ID0g
ZmFsc2U7CisJCX0KKwkJaWYgKHJhZGl4X3RyZWVfZGVyZWZfcmV0cnkoKnNsb3QpKSB7CisJCQlw
cmludGsoInJldHJ5ICVsZFxuIiwgaXRlci5pbmRleCk7CisJCQlzbG90ID0gcmFkaXhfdHJlZV9p
dGVyX3JldHJ5KCZpdGVyKTsKKwkJCWNvbnRpbnVlOworCQl9CisJfQorCisJcmFkaXhfdHJlZV9k
ZWxldGUoJnJvb3QsIDApOworCXJhZGl4X3RyZWVfZGVsZXRlKCZyb290LCAxKTsKK30KKwogdm9p
ZCBfX2luaXQgcmFkaXhfdHJlZV9pbml0KHZvaWQpCiB7CiAJcmFkaXhfdHJlZV9ub2RlX2NhY2hl
cCA9IGttZW1fY2FjaGVfY3JlYXRlKCJyYWRpeF90cmVlX25vZGUiLApAQCAtMTQ5OSw0ICsxNTU5
LDYgQEAgdm9pZCBfX2luaXQgcmFkaXhfdHJlZV9pbml0KHZvaWQpCiAJCQlyYWRpeF90cmVlX25v
ZGVfY3Rvcik7CiAJcmFkaXhfdHJlZV9pbml0X21heGluZGV4KCk7CiAJaG90Y3B1X25vdGlmaWVy
KHJhZGl4X3RyZWVfY2FsbGJhY2ssIDApOworCisJdGVzdF9pdGVyX3JldHJ5KCk7CiB9Cg==
--001a113dc134935644052aedbcc2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
