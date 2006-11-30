Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id kAUK7Kos008317
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 12:07:20 -0800
Received: from nf-out-0910.google.com (nfby25.prod.google.com [10.48.101.25])
	by zps77.corp.google.com with ESMTP id kAUK7ILa007393
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 12:07:19 -0800
Received: by nf-out-0910.google.com with SMTP id y25so4304920nfb
        for <linux-mm@kvack.org>; Thu, 30 Nov 2006 12:07:18 -0800 (PST)
Message-ID: <6599ad830611301207q4e4ab485lb0d3c99680db5a2a@mail.gmail.com>
Date: Thu, 30 Nov 2006 12:07:17 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <Pine.LNX.4.64.0611301158560.24331@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <20061130201232.7d5f5578.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830611300325h3269a185x5794b0c585d985c0@mail.gmail.com>
	 <Pine.LNX.4.64.0611301027340.23649@schroedinger.engr.sgi.com>
	 <6599ad830611301035u36a111dfye8c9414d257ebe07@mail.gmail.com>
	 <Pine.LNX.4.64.0611301037590.23732@schroedinger.engr.sgi.com>
	 <6599ad830611301109n8c4637ei338ecb4395c3702b@mail.gmail.com>
	 <Pine.LNX.4.64.0611301139420.24215@schroedinger.engr.sgi.com>
	 <6599ad830611301153i231765a0ke46846bcb73258d6@mail.gmail.com>
	 <Pine.LNX.4.64.0611301158560.24331@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/30/06, Christoph Lameter <clameter@sgi.com> wrote:
> >
> > Why is that a problem? If the vma has gone away, then there's no need
> > to reestablish the pte. And remove_file_migration_ptes() appears to be
> > adequately protected against races with unlink_file_vma() since they
> > both take i_mmap_sem.
>
> We are talking about anonymous pages here.

No, I was talking about pagecache pages by this point - you'd
mentioned them as the case where page_mapcount() can be 0 for a long
period of time.

> You cannot figure out
> that the vma is gone since that was the only connection to the process.
> Hmm... Not true we still have a migration pte in that processes space. But
> we cannot find the process without the anon_vma.

What did you think of the approach that I proposed of adding a
migration count to anon_vma? unlink_anon_vma() doesn't free the
anon_vma if migration count is non-zero.

When gathering pages for migration, we use page_lock_anon_vma() to get
the anon_vma; if it returns NULL or has an empty vma list we skip the
page, else we bump migration count (and mapcount?) by 1 and unlock.
That will guarantee that the anon_vma sticks around until the end of
the migration.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
