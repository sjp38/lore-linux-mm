Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8B4818D0039
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 03:18:02 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p0I8Ht04032606
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 00:17:59 -0800
Received: from qyk33 (qyk33.prod.google.com [10.241.83.161])
	by wpaz9.hot.corp.google.com with ESMTP id p0I8HrNI011215
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 00:17:54 -0800
Received: by qyk33 with SMTP id 33so5918915qyk.16
        for <linux-mm@kvack.org>; Tue, 18 Jan 2011 00:17:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110117191359.GI2212@cmpxchg.org>
References: <20110117191359.GI2212@cmpxchg.org>
Date: Tue, 18 Jan 2011 00:17:53 -0800
Message-ID: <AANLkTim_eDn-BS5OwmdowXMX75XgFWdcUepMJ5YBX1R7@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] memory control groups
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 17, 2011 at 11:14 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> on the MM summit, I would like to talk about the current state of
> memory control groups, the features and extensions that are currently
> being developed for it, and what their status is.

+1 - there is a lot to discuss about memcg...

> I am especially interested in talking about the current runtime memory
> overhead memcg comes with (1% of ram) and what we can do to shrink it.
>
> In comparison to how efficiently struct page is packed, and given that
> distro kernels come with memcg enabled per default, I think we should
> put a bit more thought into how struct page_cgroup (which exists for
> every page in the system as well) is organized.
>
> I have a patch series that removes the page backpointer from struct
> page_cgroup by storing a node ID (or section ID, depending on whether
> sparsemem is configured) in the free bits of pc->flags.
>
> I also plan on replacing the pc->mem_cgroup pointer with an ID
> (KAMEZAWA-san has patches for that), and move it to pc->flags too.
> Every flag not used means doubling the amount of possible control
> groups, so I have patches that get rid of some flags currently
> allocated, including PCG_CACHE, PCG_ACCT_LRU, and PCG_MIGRATION.
>
> [ I meant to send those out much earlier already, but a bug in the
> migration rework was not responding to my yelling 'Marco', and now my
> changes collide horribly with THP, so it will take another rebase. ]
>
> The per-memcg dirty accounting work e.g. allocates a bunch of new bits
> in pc->flags and I'd like to hash out if this leaves enough room for
> the structure packing I described, or whether we can come up with a
> different way of tracking state.

This is probably longer term, but I would love to get rid of the
duplication between global LRU and per-cgroup LRU. Global LRU could be
approximated by scanning all per-cgroup LRU lists (in mounts
proportional to the list lengths).

> Would other people be interested in discussing this?

Definitely.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
