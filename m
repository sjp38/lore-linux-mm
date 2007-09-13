Date: Thu, 13 Sep 2007 11:32:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04 of 24] serialize oom killer
In-Reply-To: <Pine.LNX.4.64.0709121658450.4489@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709131126370.27997@chino.kir.corp.google.com>
References: <871b7a4fd566de081120.1187786931@v2.random> <Pine.LNX.4.64.0709121658450.4489@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: pj@sgi.com, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, Christoph Lameter wrote:

> We are already serializing the cpuset lock. cpuset_lock takes a per cpuset 
> mutex! So OOM killing is already serialized per cpuset as it should be.
> 

The problem is that cpuset_lock() is a mutex and doesn't exit the OOM 
killer immediately if it can't be locked.  This is a problem that we've 
encountered before where multiple tasks enter the OOM killer and sleep 
waiting for the lock.  Then one instance of the OOM killer kills current 
and the cpuset is no longer OOM, but the other threads waiting on the 
mutex will still kill tasks unnecessarily after taking cpuset_lock().

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
