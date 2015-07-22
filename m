Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id E71E36B0038
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 20:04:04 -0400 (EDT)
Received: by qgy5 with SMTP id 5so95884407qgy.3
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 17:04:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f51si22946921qge.76.2015.07.21.17.04.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 17:04:03 -0700 (PDT)
Date: Wed, 22 Jul 2015 08:03:57 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH 2/3] perpuc: check pcpu_first_chunk and
 pcpu_reserved_chunk to avoid handling them twice
Message-ID: <20150722000357.GA1834@dhcp-17-102.nay.redhat.com>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
 <1437404130-5188-2-git-send-email-bhe@redhat.com>
 <20150721152840.GG15934@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150721152840.GG15934@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Tejun,

On 07/21/15 at 11:28am, Tejun Heo wrote:
> On Mon, Jul 20, 2015 at 10:55:29PM +0800, Baoquan He wrote:
> > In pcpu_setup_first_chunk() pcpu_reserved_chunk is assigned to point to
> > static chunk. While pcpu_first_chunk is got from below code:
> > 
> > 	pcpu_first_chunk = dchunk ?: schunk;
> > 
> > Then it could point to static chunk too if dynamic chunk doesn't exist. So
> > in this patch adding a check in percpu_init_late() to see if pcpu_first_chunk
> > is equal to pcpu_reserved_chunk. Only if they are not equal we add
> > pcpu_reserved_chunk to the target array.
> 
> So, I don't think this is actually possible.  dyn_size can't be zero
> so if reserved chunk is created, dyn chunk is also always created and
> thus first chunk can't equal reserved chunk.  It might be useful to
> add some comments explaining this or maybe WARN_ON() but I don't think
> this path is necessary.

Thanks for your reviewing.

Yes, dyn_size can't be zero. But in pcpu_setup_first_chunk(), the local
variable dyn_size could be zero caused by below code:

if (ai->reserved_size) {
                schunk->free_size = ai->reserved_size;
                pcpu_reserved_chunk = schunk;
                pcpu_reserved_chunk_limit = ai->static_size +
ai->reserved_size;
        } else {
                schunk->free_size = dyn_size;
                dyn_size = 0;                   /* dynamic area covered
*/
        }

So if no reserved_size dyn_size is assigned to zero, and is checked to
see if dchunk need be created in below code:
	/* init dynamic chunk if necessary */
        if (dyn_size) {
		...
	}

I think v1 patch is a little ugly, so made a v2 like this:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
