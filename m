Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id C15706B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 11:19:45 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2773958pbb.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 08:19:45 -0700 (PDT)
Date: Thu, 10 May 2012 08:19:41 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
Message-ID: <20120510151941.GA18302@kroah.com>
References: <1336027242-372-1-git-send-email-minchan@kernel.org>
 <1336027242-372-3-git-send-email-minchan@kernel.org>
 <4FA28907.9020300@vflare.org>
 <4FA2A2F0.3030509@linux.vnet.ibm.com>
 <4FA33DF6.8060107@kernel.org>
 <20120509201918.GA7288@kroah.com>
 <4FAB21E7.7020703@kernel.org>
 <20120510140215.GC26152@phenom.dumpdata.com>
 <4FABD503.4030808@vflare.org>
 <4FABDA9F.1000105@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FABDA9F.1000105@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 10, 2012 at 10:11:27AM -0500, Seth Jennings wrote:
> On 05/10/2012 09:47 AM, Nitin Gupta wrote:
> 
> > On 5/10/12 10:02 AM, Konrad Rzeszutek Wilk wrote:
> >> struct zs {
> >>     void *ptr;
> >> };
> >>
> >> And pass that structure around?
> >>
> > 
> > A minor problem is that we store this handle value in a radix tree node.
> > If we wrap it as a struct, then we will not be able to store it directly
> > in the node -- the node will have to point to a 'struct zs'. This will
> > unnecessarily waste sizeof(void *) for every object stored.
> 
> 
> I don't think so. You can use the fact that for a struct zs var, &var
> and &var->ptr are the same.
> 
> For the structure above:
> 
> void * zs_to_void(struct zs *p) { return p->ptr; }
> struct zs * void_to_zs(void *p) { return (struct zs *)p; }

Do like what the rest of the kernel does and pass around *ptr and use
container_of to get 'struct zs'.  Yes, they resolve to the same pointer
right now, but you shouldn't "expect" to to be the same.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
