Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id kAUNmYrL009468
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 15:48:34 -0800
Received: from nf-out-0910.google.com (nfcx37.prod.google.com [10.48.125.37])
	by zps37.corp.google.com with ESMTP id kAUNlO9m022538
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 15:48:28 -0800
Received: by nf-out-0910.google.com with SMTP id x37so3208457nfc
        for <linux-mm@kvack.org>; Thu, 30 Nov 2006 15:48:28 -0800 (PST)
Message-ID: <6599ad830611301548y66e5e66eo2f61df940a66711a@mail.gmail.com>
Date: Thu, 30 Nov 2006 15:48:28 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <Pine.LNX.4.64.0611301540390.13297@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <Pine.LNX.4.64.0611301037590.23732@schroedinger.engr.sgi.com>
	 <6599ad830611301109n8c4637ei338ecb4395c3702b@mail.gmail.com>
	 <Pine.LNX.4.64.0611301139420.24215@schroedinger.engr.sgi.com>
	 <6599ad830611301153i231765a0ke46846bcb73258d6@mail.gmail.com>
	 <Pine.LNX.4.64.0611301158560.24331@schroedinger.engr.sgi.com>
	 <6599ad830611301207q4e4ab485lb0d3c99680db5a2a@mail.gmail.com>
	 <Pine.LNX.4.64.0611301211270.24331@schroedinger.engr.sgi.com>
	 <6599ad830611301333v48f2da03g747c088ed3b4ad60@mail.gmail.com>
	 <Pine.LNX.4.64.0611301540390.13297@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/30/06, Christoph Lameter <clameter@sgi.com> wrote:
> I think you initial suggestion of adding a counter to the anon_vma may
> work. Here is a patch that may allow us to keep the anon_vma around
> without holding mmap_sem. Seems to be simple.

Don't we need to bump the mapcount? If we don't, then the page gets
unmapped by the migration prep, and if we race with anyone trying to
map it they may allocate a new anon_vma and replace it.

> --- linux-2.6.19-rc6-mm2.orig/mm/migrate.c      2006-11-29 18:37:17.797934398 -0600
> +++ linux-2.6.19-rc6-mm2/mm/migrate.c   2006-11-30 17:39:48.429639786 -0600
> @@ -218,6 +218,7 @@ static void remove_anon_migration_ptes(s
>         struct anon_vma *anon_vma;
>         struct vm_area_struct *vma;
>         unsigned long mapping;
> +       int empty;
>
>         mapping = (unsigned long)new->mapping;
>
> @@ -229,11 +230,15 @@ static void remove_anon_migration_ptes(s
>          */
>         anon_vma = (struct anon_vma *) (mapping - PAGE_MAPPING_ANON);
>         spin_lock(&anon_vma->lock);
> +       anon_vma->migration_count--;
>
>         list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
>                 remove_migration_pte(vma, old, new);
>
> +       empty = list_empty(&anon_vma->head);

I think we need to check for migration_count being non-zero here, just
in case two processes try to migrate the same page at once. Or maybe
just say that if migration_count is non-zero, the second migrator just
ignores the page?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
