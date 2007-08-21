From: Dave McCracken <dave.mccracken@oracle.com>
Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water marks
Date: Tue, 21 Aug 2007 10:51:35 -0500
References: <20070820215040.937296148@sgi.com>
In-Reply-To: <20070820215040.937296148@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200708211051.36569.dave.mccracken@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 20 August 2007, Christoph Lameter wrote:
> 1. First reclaiming non dirty pages. Dirty pages are deferred until reclaim
>    has reestablished the high marks. Then all the dirty pages (the laundry)
>    is written out.

I don't buy it.  What happens when there aren't enough clean pages in the 
system to achieve the high water mark?  I'm guessing we'd get a quick OOM (as 
observed by Peter).

> 2. Reclaim is essentially complete during the writeout phase. So we remove
>    PF_MEMALLOC and allow recursive reclaim if we still run into trouble
>    during writeout.

You're assuming the system is static and won't allocate new pages behind your 
back.  We could be back to critically low memory before the write happens.

More broadly, we need to be proactive about getting dirty pages cleaned before 
they consume the system.  Deferring the write just makes it harder to keep 
up.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
