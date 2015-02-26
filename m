Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id C42BA6B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 20:04:58 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id h15so10817879igd.3
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 17:04:58 -0800 (PST)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id x16si230439icx.78.2015.02.25.17.04.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 17:04:58 -0800 (PST)
Received: by mail-ig0-f175.google.com with SMTP id hn18so40489809igb.2
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 17:04:58 -0800 (PST)
Date: Wed, 25 Feb 2015 17:04:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm: remove GFP_THISNODE
In-Reply-To: <alpine.DEB.2.11.1502251855330.14795@gentwo.org>
Message-ID: <alpine.DEB.2.10.1502251701340.12985@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.11.1502251855330.14795@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, dev@openvswitch.org

On Wed, 25 Feb 2015, Christoph Lameter wrote:

> On Wed, 25 Feb 2015, David Rientjes wrote:
> 
> > NOTE: this is not about __GFP_THISNODE, this is only about GFP_THISNODE.
> 
> Well but then its not removing it. You are replacing it with an inline
> function.
> 

Removing GFP_THISNODE, not __GFP_THISNODE.  GFP_THISNODE, as the commit 
message says, is a special collection of flags that means "never try 
reclaim" and people confuse it for __GFP_THISNODE.

There are legitimate usecases where we want __GFP_THISNODE, in other words 
restricting the allocation to only a specific node, and try reclaim but 
not warn in failure or retry.  The most notable example is in the followup 
patch for thp, both for page faults and khugepaged, where we want to 
target the local node but silently fallback to small pages instead.

This removes the special "no reclaim" behavior of __GFP_THISNODE | 
__GFP_NORETRY | __GFP_NOWARN and relies on clearing __GFP_WAIT instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
