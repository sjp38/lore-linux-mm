Date: Thu, 30 Nov 2006 18:23:40 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <6599ad830611301548y66e5e66eo2f61df940a66711a@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0611301821270.14059@schroedinger.engr.sgi.com>
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
 <6599ad830611301548y66e5e66eo2f61df940a66711a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Nov 2006, Paul Menage wrote:

> Don't we need to bump the mapcount? If we don't, then the page gets
> unmapped by the migration prep, and if we race with anyone trying to
> map it they may allocate a new anon_vma and replace it.

Allocate a new vma for an existing anon page? That never happens. We may 
do COW in which case the page is copied.

> > +       empty = list_empty(&anon_vma->head);
> 
> I think we need to check for migration_count being non-zero here, just
> in case two processes try to migrate the same page at once. Or maybe
> just say that if migration_count is non-zero, the second migrator just
> ignores the page?

Right we need to check for the migration_count being zero. The one that 
zeros it must free the anon_vma.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
