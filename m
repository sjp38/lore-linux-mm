Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 538636B0069
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 10:44:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e69so8810822pfg.1
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 07:44:52 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 7si8592067ple.699.2017.10.02.07.44.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 07:44:51 -0700 (PDT)
Subject: Re: [RFC] [PATCH] mm,oom: Offload OOM notify callback to a kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171002115035.7sph6ul6hsszdwa4@dhcp22.suse.cz>
	<201710022205.IGD04659.HSOMJFFQtFOLOV@I-love.SAKURA.ne.jp>
	<20171002131330.5c5mpephrosfuxsa@dhcp22.suse.cz>
	<201710022252.DDJ51535.JFQSLFHFVOtOOM@I-love.SAKURA.ne.jp>
	<20171002171641-mutt-send-email-mst@kernel.org>
In-Reply-To: <20171002171641-mutt-send-email-mst@kernel.org>
Message-Id: <201710022344.JII17368.HQtLOMJOOSFFVF@I-love.SAKURA.ne.jp>
Date: Mon, 2 Oct 2017 23:44:45 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: mhocko@kernel.org, linux-mm@kvack.org

Michael S. Tsirkin wrote:
> > Yes, conditional GFP_KERNEL allocation attempt from virtqueue_add() might
> > still cause this deadlock. But that depends on whether you can trigger this
> > deadlock. As far as I know, there is no report. Thus, I think that avoiding
> > theoretical deadlock using timeout will be sufficient.
> 
> 
> So first of all IMHO GFP_KERNEL allocations do not happen in
> virtqueue_add_outbuf at all. They only trigger through add_sgs.

I did not notice that total_sg == 1 is true for virtqueue_add_outbuf().

> 
> IMHO this is an API bug, we should just drop the gfp parameter
> from this API.

OK.

> 
> 
> so the issue is balloon_page_enqueue only.
> 

Since you explained that there is "the deflate on OOM flag", we don't
want to skip deflating upon lock contention.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
