Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 07A54900049
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 11:03:23 -0400 (EDT)
Received: by lbvp9 with SMTP id p9so9469433lbv.8
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 08:03:22 -0700 (PDT)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [2a02:6b8:0:1402::10])
        by mx.google.com with ESMTPS id ai6si2459407lbc.147.2015.03.11.08.03.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Mar 2015 08:03:18 -0700 (PDT)
Message-ID: <5500592D.4090309@yandex-team.ru>
Date: Wed, 11 Mar 2015 18:03:09 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm, procfs: account for shmem swap in /proc/pid/smaps
References: <1424958666-18241-1-git-send-email-vbabka@suse.cz>	<1424958666-18241-3-git-send-email-vbabka@suse.cz> <CALYGNiPn-C6AESik_BrQBEJpOsvcy7qG_sacAyf+O24A6P9kyA@mail.gmail.com>
In-Reply-To: <CALYGNiPn-C6AESik_BrQBEJpOsvcy7qG_sacAyf+O24A6P9kyA@mail.gmail.com>
Content-Type: multipart/mixed;
 boundary="------------080407040304000000060205"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Jerome Marchand <jmarchan@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>

This is a multi-part message in MIME format.
--------------080407040304000000060205
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 11.03.2015 15:30, Konstantin Khlebnikov wrote:
> On Thu, Feb 26, 2015 at 4:51 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> Currently, /proc/pid/smaps will always show "Swap: 0 kB" for shmem-backed
>> mappings, even if the mapped portion does contain pages that were swapped out.
>> This is because unlike private anonymous mappings, shmem does not change pte
>> to swap entry, but pte_none when swapping the page out. In the smaps page
>> walk, such page thus looks like it was never faulted in.
>
> Maybe just add count of swap entries allocated by mapped shmem into
> swap usage of this vma? That's isn't exactly correct for partially
> mapped shmem but this is something weird anyway.

Something like that (see patch in attachment)

>
>>
>> This patch changes smaps_pte_entry() to determine the swap status for such
>> pte_none entries for shmem mappings, similarly to how mincore_page() does it.
>> Swapped out pages are thus accounted for.
>>
>> The accounting is arguably still not as precise as for private anonymous
>> mappings, since now we will count also pages that the process in question never
>> accessed, but only another process populated them and then let them become
>> swapped out. I believe it is still less confusing and subtle than not showing
>> any swap usage by shmem mappings at all. Also, swapped out pages only becomee a
>> performance issue for future accesses, and we cannot predict those for neither
>> kind of mapping.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>   Documentation/filesystems/proc.txt |  3 ++-
>>   fs/proc/task_mmu.c                 | 20 ++++++++++++++++++++
>>   2 files changed, 22 insertions(+), 1 deletion(-)
>>
>> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
>> index d4f56ec..8b30543 100644
>> --- a/Documentation/filesystems/proc.txt
>> +++ b/Documentation/filesystems/proc.txt
>> @@ -437,7 +437,8 @@ indicates the amount of memory currently marked as referenced or accessed.
>>   a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
>>   and a page is modified, the file page is replaced by a private anonymous copy.
>>   "Swap" shows how much would-be-anonymous memory is also used, but out on
>> -swap.
>> +swap. For shmem mappings, "Swap" shows how much of the mapped portion of the
>> +underlying shmem object is on swap.
>>
>>   "VmFlags" field deserves a separate description. This member represents the kernel
>>   flags associated with the particular virtual memory area in two letter encoded
>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>> index 956b75d..0410309 100644
>> --- a/fs/proc/task_mmu.c
>> +++ b/fs/proc/task_mmu.c
>> @@ -13,6 +13,7 @@
>>   #include <linux/swap.h>
>>   #include <linux/swapops.h>
>>   #include <linux/mmu_notifier.h>
>> +#include <linux/shmem_fs.h>
>>
>>   #include <asm/elf.h>
>>   #include <asm/uaccess.h>
>> @@ -496,6 +497,25 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
>>                          mss->swap += PAGE_SIZE;
>>                  else if (is_migration_entry(swpent))
>>                          page = migration_entry_to_page(swpent);
>> +       } else if (IS_ENABLED(CONFIG_SHMEM) && IS_ENABLED(CONFIG_SWAP) &&
>> +                                       pte_none(*pte) && vma->vm_file) {
>> +               struct address_space *mapping =
>> +                       file_inode(vma->vm_file)->i_mapping;
>> +
>> +               /*
>> +                * shmem does not use swap pte's so we have to consult
>> +                * the radix tree to account for swap
>> +                */
>> +               if (shmem_mapping(mapping)) {
>> +                       page = find_get_entry(mapping, pgoff);
>> +                       if (page) {
>> +                               if (radix_tree_exceptional_entry(page))
>> +                                       mss->swap += PAGE_SIZE;
>> +                               else
>> +                                       page_cache_release(page);
>> +                       }
>> +                       page = NULL;
>> +               }
>>          }
>>
>>          if (!page)
>> --
>> 2.1.4
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-doc" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


--------------080407040304000000060205
Content-Type: text/plain; charset=UTF-8;
 name="shmem-show-swap-usage-in-smaps"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="shmem-show-swap-usage-in-smaps"

c2htZW06IHNob3cgc3dhcCB1c2FnZSBpbiBzbWFwcwoKRnJvbTogS29uc3RhbnRpbiBLaGxl
Ym5pa292IDxraGxlYm5pa292QHlhbmRleC10ZWFtLnJ1PgoKU2lnbmVkLW9mZi1ieTogS29u
c3RhbnRpbiBLaGxlYm5pa292IDxraGxlYm5pa292QHlhbmRleC10ZWFtLnJ1PgotLS0KIGZz
L3Byb2MvdGFza19tbXUuYyB8ICAgIDMgKysrCiBpbmNsdWRlL2xpbnV4L21tLmggfCAgICAy
ICsrCiBtbS9zaG1lbS5jICAgICAgICAgfCAgICA4ICsrKysrKysrCiAzIGZpbGVzIGNoYW5n
ZWQsIDEzIGluc2VydGlvbnMoKykKCmRpZmYgLS1naXQgYS9mcy9wcm9jL3Rhc2tfbW11LmMg
Yi9mcy9wcm9jL3Rhc2tfbW11LmMKaW5kZXggOTU2Yjc1ZDYxODA5Li4wOWE5NGNlYzE1OWUg
MTAwNjQ0Ci0tLSBhL2ZzL3Byb2MvdGFza19tbXUuYworKysgYi9mcy9wcm9jL3Rhc2tfbW11
LmMKQEAgLTYyNCw2ICs2MjQsOSBAQCBzdGF0aWMgaW50IHNob3dfc21hcChzdHJ1Y3Qgc2Vx
X2ZpbGUgKm0sIHZvaWQgKnYsIGludCBpc19waWQpCiAJLyogbW1hcF9zZW0gaXMgaGVsZCBp
biBtX3N0YXJ0ICovCiAJd2Fsa19wYWdlX3ZtYSh2bWEsICZzbWFwc193YWxrKTsKIAorCWlm
ICh2bWEtPnZtX29wcyAmJiB2bWEtPnZtX29wcy0+Z2V0X3N3YXBfdXNhZ2UpCisJCW1zcy5z
d2FwICs9IHZtYS0+dm1fb3BzLT5nZXRfc3dhcF91c2FnZSh2bWEpIDw8IFBBR0VfU0hJRlQ7
CisKIAlzaG93X21hcF92bWEobSwgdm1hLCBpc19waWQpOwogCiAJc2VxX3ByaW50ZihtLApk
aWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9tbS5oIGIvaW5jbHVkZS9saW51eC9tbS5oCmlu
ZGV4IDY1NzFkZDc4ZTk4NC4uNDc3YTQ2OTg3ODU5IDEwMDY0NAotLS0gYS9pbmNsdWRlL2xp
bnV4L21tLmgKKysrIGIvaW5jbHVkZS9saW51eC9tbS5oCkBAIC0yOTIsNiArMjkyLDggQEAg
c3RydWN0IHZtX29wZXJhdGlvbnNfc3RydWN0IHsKIAkgKi8KIAlzdHJ1Y3QgcGFnZSAqKCpm
aW5kX3NwZWNpYWxfcGFnZSkoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsCiAJCQkJCSAg
dW5zaWduZWQgbG9uZyBhZGRyKTsKKworCXVuc2lnbmVkIGxvbmcgKCpnZXRfc3dhcF91c2Fn
ZSkoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEpOwogfTsKIAogc3RydWN0IG1tdV9nYXRo
ZXI7CmRpZmYgLS1naXQgYS9tbS9zaG1lbS5jIGIvbW0vc2htZW0uYwppbmRleCBjZjJkMGNh
MDEwYmMuLjQ5MmY3OGY1MWZjMiAxMDA2NDQKLS0tIGEvbW0vc2htZW0uYworKysgYi9tbS9z
aG1lbS5jCkBAIC0xMzYzLDYgKzEzNjMsMTMgQEAgc3RhdGljIHN0cnVjdCBtZW1wb2xpY3kg
KnNobWVtX2dldF9wb2xpY3koc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsCiB9CiAjZW5k
aWYKIAorc3RhdGljIHVuc2lnbmVkIGxvbmcgc2htZW1fZ2V0X3N3YXBfdXNhZ2Uoc3RydWN0
IHZtX2FyZWFfc3RydWN0ICp2bWEpCit7CisJc3RydWN0IGlub2RlICppbm9kZSA9IGZpbGVf
aW5vZGUodm1hLT52bV9maWxlKTsKKworCXJldHVybiBTSE1FTV9JKGlub2RlKS0+c3dhcHBl
ZDsKK30KKwogaW50IHNobWVtX2xvY2soc3RydWN0IGZpbGUgKmZpbGUsIGludCBsb2NrLCBz
dHJ1Y3QgdXNlcl9zdHJ1Y3QgKnVzZXIpCiB7CiAJc3RydWN0IGlub2RlICppbm9kZSA9IGZp
bGVfaW5vZGUoZmlsZSk7CkBAIC0zMTk4LDYgKzMyMDUsNyBAQCBzdGF0aWMgY29uc3Qgc3Ry
dWN0IHZtX29wZXJhdGlvbnNfc3RydWN0IHNobWVtX3ZtX29wcyA9IHsKIAkuc2V0X3BvbGlj
eSAgICAgPSBzaG1lbV9zZXRfcG9saWN5LAogCS5nZXRfcG9saWN5ICAgICA9IHNobWVtX2dl
dF9wb2xpY3ksCiAjZW5kaWYKKwkuZ2V0X3N3YXBfdXNhZ2UJPSBzaG1lbV9nZXRfc3dhcF91
c2FnZSwKIH07CiAKIHN0YXRpYyBzdHJ1Y3QgZGVudHJ5ICpzaG1lbV9tb3VudChzdHJ1Y3Qg
ZmlsZV9zeXN0ZW1fdHlwZSAqZnNfdHlwZSwK
--------------080407040304000000060205--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
