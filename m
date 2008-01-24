Date: Wed, 23 Jan 2008 19:13:35 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Fix boot problem in situations where the boot CPU is
 running on a memoryless node
In-Reply-To: <20080123213637.GE3848@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0801231906310.17620@schroedinger.engr.sgi.com>
References: <20080123125236.GA18876@aepfle.de> <20080123135513.GA14175@csn.ul.ie>
 <Pine.LNX.4.64.0801231611160.20050@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0801231626320.21475@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0801231648140.23343@sbz-30.cs.Helsinki.FI>
 <20080123155655.GB20156@csn.ul.ie> <Pine.LNX.4.64.0801231906520.1028@sbz-30.cs.Helsinki.FI>
 <20080123195220.GB3848@us.ibm.com> <84144f020801231302g2cafdda9kf7f916121dc56aa5@mail.gmail.com>
 <Pine.LNX.4.64.0801231312580.15681@schroedinger.engr.sgi.com>
 <20080123213637.GE3848@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, Olaf Hering <olaf@aepfle.de>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2008, Nishanth Aravamudan wrote:

> Right, so it might have functioned before, but the correctness was
> wobbly at best... Certainly the memoryless patch series has tightened
> that up, but we missed these SLAB issues.
> 
> I see that your patch fixed Olaf's machine, Pekka. Nice work on
> everyone's part tracking this stuff down.

Another important result is that I found that GFP_THISNODE is actually 
required for proper SLAB operation and not only an optimization. Fallback 
can lead to very bad results. I have two customer reported instances of 
SLAB corruption here that can be explained now due to fallback to another 
node. Foreign objects enter the per cpu queue. The wrong node lock is 
taken during cache_flusharray(). Fields in the struct slab can become 
corrupted. It typically hits the list field and the inuse field.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
