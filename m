Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2807C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 12:38:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86AC62085A
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 12:38:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Kw5dYDPC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86AC62085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13C346B0008; Mon, 19 Aug 2019 08:38:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EDA36B000A; Mon, 19 Aug 2019 08:38:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1DA56B000C; Mon, 19 Aug 2019 08:38:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0014.hostedemail.com [216.40.44.14])
	by kanga.kvack.org (Postfix) with ESMTP id CEB286B0008
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 08:38:43 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 83FA721F0
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 12:38:43 +0000 (UTC)
X-FDA: 75839131326.18.bulb71_2f03ddc866c63
X-HE-Tag: bulb71_2f03ddc866c63
X-Filterd-Recvd-Size: 5004
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 12:38:42 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id 125so1223196qkl.6
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 05:38:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=kcl2qjS+S92HqUsWy/tjB3qoqqgCsFoa4lNkLGm9eqU=;
        b=Kw5dYDPC3RCMymknBRy1kIe+iDY+gtMlsFiGqHh0HRHDdkA1mVDMtLhKZZ0CG2KFv3
         LVYv+T9FGmeylYTDi+kh5M9/Ntuhs1KUREG17679sHQhmPsIVOwRG2eQbHs3GIhuH2De
         teqAib33hkHc6gnoEGXxQH7ITS22Bxbhltn46+fBqORa9Jb9jv/kTbwn4XmLd12IuyM5
         /yPvmu7+YELsKojRcfZOMaNBoqJ1qtrNgLmHYKwBdl9/gdtpWh1vLo6xyTHwMVm7oA6I
         7K86YItRgHihPHUhSIgXXcp4Bm7RF41NJgLrAPGgKKR410ENEsEKjr9s9uuDjUGnheP5
         bsRw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=kcl2qjS+S92HqUsWy/tjB3qoqqgCsFoa4lNkLGm9eqU=;
        b=sAvuKF+owembGNGt+KV1Fgu9vz/OB4EKjHEb3O0NJ0d29LKfddFgBgzfzYVZST5j2E
         CO3N2kC5JHYR4tl/Tg3lrVmNX/HhWYWMqJV/K7o4xFzMCREFm1T9d+UksUrao4kusr1c
         Z3PNym9a/HXHJollRW8OS81UB/eo+caJ/JpGV1hRBgoNhW73/vnYcFv45m/0cERkyEtn
         RfV4nqiYiO29avp8jcCUlVmGjprsADw2k0m//4OvwlbKcXPOF9Pdhyl+BtPRkVp882Wk
         DkGrww4rC6Qaot6miXaAjo8raeyCf3LN/A2fW3f6+5KGitPitPhKLgbLJA29Wc/eqaSy
         qkQQ==
X-Gm-Message-State: APjAAAW9Kj2iH7a206BR32k16h6it+lbEC8/TFCuCvpYlhzGay4CPhWJ
	kTEOERoLo355Mheb8vo5NMCxTA==
X-Google-Smtp-Source: APXvYqzbQNTYwMVTncdSqshKmZtcSi8KUDzyxSrbcJIuOywIrId5vXd75IqedVtc8bcWHqWRX6iGcQ==
X-Received: by 2002:a37:a14a:: with SMTP id k71mr20104946qke.281.1566218322367;
        Mon, 19 Aug 2019 05:38:42 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id r15sm6916339qtp.94.2019.08.19.05.38.41
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Aug 2019 05:38:41 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hzgvp-0001vJ-9J; Mon, 19 Aug 2019 09:38:41 -0300
Date: Mon, 19 Aug 2019 09:38:41 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Theodore Ts'o <tytso@mit.edu>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 00/19] RDMA/FS DAX truncate proposal V1,000,002 ;-)
Message-ID: <20190819123841.GC5058@ziepe.ca>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190814101714.GA26273@quack2.suse.cz>
 <20190814180848.GB31490@iweiny-DESK2.sc.intel.com>
 <20190815130558.GF14313@quack2.suse.cz>
 <20190816190528.GB371@iweiny-DESK2.sc.intel.com>
 <20190817022603.GW6129@dread.disaster.area>
 <20190819063412.GA20455@quack2.suse.cz>
 <20190819092409.GM7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190819092409.GM7777@dread.disaster.area>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 07:24:09PM +1000, Dave Chinner wrote:

> So that leaves just the normal close() syscall exit case, where the
> application has full control of the order in which resources are
> released. We've already established that we can block in this
> context.  Blocking in an interruptible state will allow fatal signal
> delivery to wake us, and then we fall into the
> fatal_signal_pending() case if we get a SIGKILL while blocking.

The major problem with RDMA is that it doesn't always wait on close() for the
MR holding the page pins to be destoyed. This is done to avoid a
deadlock of the form:

   uverbs_destroy_ufile_hw()
      mutex_lock()
       [..]
        mmput()
         exit_mmap()
          remove_vma()
           fput();
            file_operations->release()
             ib_uverbs_close()
              uverbs_destroy_ufile_hw()
               mutex_lock()   <-- Deadlock

But, as I said to Ira earlier, I wonder if this is now impossible on
modern kernels and we can switch to making the whole thing
synchronous. That would resolve RDMA's main problem with this.

Jason

