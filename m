Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out.google.com with ESMTP id kAUAjtZe018276
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 10:45:55 GMT
Received: from nf-out-0910.google.com (nfby25.prod.google.com [10.48.101.25])
	by spaceape12.eur.corp.google.com with ESMTP id kAUAjqfT030263
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 10:45:52 GMT
Received: by nf-out-0910.google.com with SMTP id y25so4117076nfb
        for <linux-mm@kvack.org>; Thu, 30 Nov 2006 02:45:52 -0800 (PST)
Message-ID: <6599ad830611300245s5c0f40bdu4231832930e9c023@mail.gmail.com>
Date: Thu, 30 Nov 2006 02:45:51 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <Pine.LNX.4.64.0611292015280.19628@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <20061130093105.d872c49d.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830611291631hd6d3e52y971c35708004db00@mail.gmail.com>
	 <Pine.LNX.4.64.0611292015280.19628@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/29/06, Christoph Lameter <clameter@sgi.com> wrote:
>
> You do not have a problem as long as you hold a mmap_sem lock on any of
> the vmas in which the page appears. Kame and I discussed several
> approached on how to avoid the issue in the past but so far there was no
> need to resolve the issue.
>

It sounds like this would be useful for memory hot-unplug too, though.
A problem worth solving?

Why isn't page_lock_anon_vma() safe to use in this case? Because after
we've established migration ptes, page_mapped() will be false and so
page_lock_anon_vma() will return NULL?
How does kswapd do this safely?

Possible approach (apologies if you've already considered and rejected this):

- add a migration_count field to anon_vma

- use page_lock_anon_vma() to get the anon_vma for a page, assuming
it's mapped; if it's unmapped or if the anon_vma that we get has no
linked vmas then we ignore it - the chances are that the page is in
the process of being freed anyway, and if someone happens to remap it
just before it's freed then we can catch it next time around.

- isolate_lru_page() can bump this for every page that it isolates

- unlink_anon_vma() won't free the anon_vma if its migration_count is >0.

- remove_anon_migration_ptes() can free the anon_vma if
migration_count is 0 and the vma list is empty.


Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
