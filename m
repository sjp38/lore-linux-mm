Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE591280266
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 15:56:18 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id n132so326081687oih.1
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 12:56:18 -0700 (PDT)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id v60si1126284ota.98.2016.09.25.12.56.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 12:56:18 -0700 (PDT)
Received: by mail-oi0-x244.google.com with SMTP id n202so12372843oig.2
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 12:56:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFxOJTOvxhv+hECHuGV+=xBHMuQitu86J=qBNmMYQ1ACSg@mail.gmail.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
 <CALXu0Ucx-6PeEk9nTD-4nZvwyVr9LLXcFGFzhctX-ucKfCygGA@mail.gmail.com>
 <CA+55aFyRG=us-EKnomo=QPE0GR1Qdxyw1Ozmuzw0EJcSr7U3hQ@mail.gmail.com>
 <CALXu0UfuwGM+H0YnfSNW6O=hgcUrmws+ihHLVB=OJWOp8YCwgw@mail.gmail.com>
 <CA+55aFzge97L-JLKZq0CTW1wtMOsnt8QzOw3b5qCMmzbKxZ5aw@mail.gmail.com> <CA+55aFxOJTOvxhv+hECHuGV+=xBHMuQitu86J=qBNmMYQ1ACSg@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 25 Sep 2016 12:56:17 -0700
Message-ID: <CA+55aFw9=wqyA4xO1KKJoH7xsj6poWFrWTddcNBR5tkDOn8SYg@mail.gmail.com>
Subject: Re: [PATCH 2/2] radix-tree: Fix optimisation problem
Content-Type: multipart/mixed; boundary=001a113cf2e29b8734053d5a673e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@linuxonhyperv.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>

--001a113cf2e29b8734053d5a673e
Content-Type: text/plain; charset=UTF-8

On Sun, Sep 25, 2016 at 12:04 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>        It gets rid of
> the ad-hoc arithmetic in radix_tree_descend(), and just makes all that
> be inside the is_sibling_entry() logic instead. Which got renamed and
> made to actually return the main sibling.

Sadly, it looks like gcc generates bad code for this approach. Looks
like it ends up testing the resulting sibling pointer twice (because
we explicitly disable -fno-delete-null-pointer-checks in the kernel,
and we have no way to say "look, I know this pointer I'm returning is
non-null").

So a smaller patch that keeps the old boolean "is_sibling_entry()" but
then actually *uses* that inside radix_tree_descend() and then tries
to make the nasty cast to "void **" more legible by making it use a
temporary variable seems to be a reasonable balance.

At least I feel like I can still read the code, but admittedly by now
that may be because I've stared at those few lines so much that I feel
like I know what's going on. So maybe the code isn't actually any more
legible after all.

.. and unlike my previous patch, it actually generates better code
than the original (while still passing the fixed test-suite, of
course). The reason seems to be exactly that temporary variable,
allowing us to just do

        entry = rcu_dereference_raw(*sibentry);

rather than doing

        entry = rcu_dereference_raw(parent->slots[offset]);

with the re-computed offset.

So I think I'll commit this unless somebody screams.

                     Linus

--001a113cf2e29b8734053d5a673e
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_itj1pmj91

IGxpYi9yYWRpeC10cmVlLmMgfCA4ICsrKystLS0tCiAxIGZpbGUgY2hhbmdlZCwgNCBpbnNlcnRp
b25zKCspLCA0IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2xpYi9yYWRpeC10cmVlLmMgYi9s
aWIvcmFkaXgtdHJlZS5jCmluZGV4IDFiN2JmNzMxNDE0MS4uOTFmMDcyN2UzY2FkIDEwMDY0NAot
LS0gYS9saWIvcmFkaXgtdHJlZS5jCisrKyBiL2xpYi9yYWRpeC10cmVlLmMKQEAgLTEwNSwxMCAr
MTA1LDEwIEBAIHN0YXRpYyB1bnNpZ25lZCBpbnQgcmFkaXhfdHJlZV9kZXNjZW5kKHN0cnVjdCBy
YWRpeF90cmVlX25vZGUgKnBhcmVudCwKIAogI2lmZGVmIENPTkZJR19SQURJWF9UUkVFX01VTFRJ
T1JERVIKIAlpZiAocmFkaXhfdHJlZV9pc19pbnRlcm5hbF9ub2RlKGVudHJ5KSkgewotCQl1bnNp
Z25lZCBsb25nIHNpYm9mZiA9IGdldF9zbG90X29mZnNldChwYXJlbnQsIGVudHJ5KTsKLQkJaWYg
KHNpYm9mZiA8IFJBRElYX1RSRUVfTUFQX1NJWkUpIHsKLQkJCW9mZnNldCA9IHNpYm9mZjsKLQkJ
CWVudHJ5ID0gcmN1X2RlcmVmZXJlbmNlX3JhdyhwYXJlbnQtPnNsb3RzW29mZnNldF0pOworCQlp
ZiAoaXNfc2libGluZ19lbnRyeShwYXJlbnQsIGVudHJ5KSkgeworCQkJdm9pZCAqKnNpYmVudHJ5
ID0gKHZvaWQgKiopIGVudHJ5X3RvX25vZGUoZW50cnkpOworCQkJb2Zmc2V0ID0gZ2V0X3Nsb3Rf
b2Zmc2V0KHBhcmVudCwgc2liZW50cnkpOworCQkJZW50cnkgPSByY3VfZGVyZWZlcmVuY2VfcmF3
KCpzaWJlbnRyeSk7CiAJCX0KIAl9CiAjZW5kaWYK
--001a113cf2e29b8734053d5a673e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
