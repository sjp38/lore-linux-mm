Received: by uproxy.gmail.com with SMTP id k40so105002ugc
        for <linux-mm@kvack.org>; Fri, 27 Jan 2006 03:07:54 -0800 (PST)
Message-ID: <84144f020601270307t7266a4ccs5071d4b288a9257f@mail.gmail.com>
Date: Fri, 27 Jan 2006 13:07:54 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 0/9] Critical Mempools
In-Reply-To: <20060127021050.f50d358d.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <1138217992.2092.0.camel@localhost.localdomain>
	 <Pine.LNX.4.62.0601260954540.15128@schroedinger.engr.sgi.com>
	 <43D954D8.2050305@us.ibm.com>
	 <Pine.LNX.4.62.0601261516160.18716@schroedinger.engr.sgi.com>
	 <43D95BFE.4010705@us.ibm.com> <20060127000304.GG10409@kvack.org>
	 <43D968E4.5020300@us.ibm.com>
	 <84144f020601262335g49c21b62qaa729732e9275c0@mail.gmail.com>
	 <20060127021050.f50d358d.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: colpatch@us.ibm.com, bcrl@kvack.org, clameter@engr.sgi.com, linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Pekka wrote:
> > As as side note, we already have __GFP_NOFAIL. How is it different
> > from GFP_CRITICAL and why aren't we improving that?

On 1/27/06, Paul Jackson <pj@sgi.com> wrote:
> Don't these two flags invoke two different mechanisms.
>   __GFP_NOFAIL can sleep for HZ/50 then retry, rather than return failure.
>   __GFP_CRITICAL can steal from the emergency pool rather than fail.
>
> I would favor renaming at least the __GFP_CRITICAL to something
> like __GFP_EMERGPOOL, to highlight the relevant distinction.

Yeah you're right. __GFP_NOFAIL guarantees to never fail but it
doesn't guarantee to actually succeed either. I think the suggested
semantics for __GFP_EMERGPOOL are that while it can fail, it tries to
avoid that by dipping into page reserves. However, I do still think
it's a bad idea to allow the slab allocator to steal whole pages for
critical allocations because in low-memory condition, it should be
fairly easy to exhaust the reserves and waste most of that memory at
the same time.

                            Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
