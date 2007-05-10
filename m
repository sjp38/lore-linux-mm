Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id l4A1QD2F012612
	for <linux-mm@kvack.org>; Thu, 10 May 2007 02:26:13 +0100
Received: from an-out-0708.google.com (anac38.prod.google.com [10.100.54.38])
	by spaceape14.eur.corp.google.com with ESMTP id l4A1Q7kg022072
	for <linux-mm@kvack.org>; Thu, 10 May 2007 02:26:08 +0100
Received: by an-out-0708.google.com with SMTP id c38so99300ana
        for <linux-mm@kvack.org>; Wed, 09 May 2007 18:26:07 -0700 (PDT)
Message-ID: <b040c32a0705091826n5b7b3602laa3650fd4763e3@mail.gmail.com>
Date: Wed, 9 May 2007 18:26:07 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [patch] check cpuset mems_allowed for sys_mbind
In-Reply-To: <Pine.LNX.4.64.0705091749180.2374@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0705091611mb35258ap334426e42d33372c@mail.gmail.com>
	 <20070509164859.15dd347b.pj@sgi.com>
	 <b040c32a0705091747x75f45eacwbe11fe106be71833@mail.gmail.com>
	 <Pine.LNX.4.64.0705091749180.2374@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/9/07, Christoph Lameter <clameter@sgi.com> wrote:
> > However, mbind shouldn't create discrepancy between what is allowed
> > and what is promised, especially with MPOL_BIND policy.  Since a
> > numa-aware app has already gone such a detail to request memory
> > placement on a specific nodemask, they fully expect memory to be
> > placed there for performance reason.  If kernel lies about it, we get
> > very unpleasant performance issue.
>
> How does the kernel lie? The memory is placed given the current cpuset and
> memory policy restrictions.

sys_mbind lies.  A task in cpuset that has mems=0-7, it can do
sys_mbind(MPOL_BIND, 0x100, ...) and such call will return success.
The app fully rely on memory allocation occurs on node 8, but that
obviously can't happen because of cpuset.  Everything goes downhill
from this point on.  Granted, app shouldn't call with such nodemask,
but the fun starts with mbind being incompatible with cpuset (it
checks against global node_online_map which includes a mask of entire
system).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
