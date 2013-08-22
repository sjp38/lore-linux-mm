Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id EA00F6B0033
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 23:21:29 -0400 (EDT)
Received: by mail-oa0-f51.google.com with SMTP id h1so2576880oag.10
        for <linux-mm@kvack.org>; Wed, 21 Aug 2013 20:21:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130821204901.GA19802@redhat.com>
References: <20130807055157.GA32278@redhat.com>
	<CAJd=RBCJv7=Qj6dPW2Ha=nq6JctnK3r7wYCAZTm=REVOZUNowg@mail.gmail.com>
	<20130807153030.GA25515@redhat.com>
	<CAJd=RBCyZU8PR7mbFUdKsWq3OH+5HccEWKMEH5u7GNHNy3esWg@mail.gmail.com>
	<20130819231836.GD14369@redhat.com>
	<CAJd=RBA-UZmSTxNX63Vni+UPZBHwP4tvzE_qp1ZaHBqcNG7Fcw@mail.gmail.com>
	<20130821204901.GA19802@redhat.com>
Date: Thu, 22 Aug 2013 11:21:28 +0800
Message-ID: <CAJd=RBBNCf5_V-nHjK0gOqS4OLMszgB7Rg_WMf4DvL-De+ZdHA@mail.gmail.com>
Subject: Re: unused swap offset / bad page map.
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Hillf Danton <dhillf@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, Aug 22, 2013 at 4:49 AM, Dave Jones <davej@redhat.com> wrote:
>
> didn't hit the bug_on, but got a bunch of
>
> [  424.077993] swap_free: Unused swap offset entry 000187d5
> [  439.377194] swap_free: Unused swap offset entry 000187e7
> [  441.998411] swap_free: Unused swap offset entry 000187ee
> [  446.956551] swap_free: Unused swap offset entry 0000245f
>
If page is reused, its swap entry is freed.

reuse_swap_page()
  delete_from_swap_cache()
    swapcache_free()
      count = swap_entry_free(p, entry, SWAP_HAS_CACHE);

If count drops to zero, then swap_free() gives warning.


--- a/mm/memory.c Wed Aug  7 16:29:34 2013
+++ b/mm/memory.c Thu Aug 22 10:44:32 2013
@@ -3123,6 +3123,7 @@ static int do_swap_page(struct mm_struct
  /* It's better to call commit-charge after rmap is established */
  mem_cgroup_commit_charge_swapin(page, ptr);

+ if (!exclusive)
  swap_free(entry);
  if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
  try_to_free_swap(page);
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
