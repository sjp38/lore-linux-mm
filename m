Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B5CBC433FF
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 08:07:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2505A20844
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 08:07:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2505A20844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC31A6B0003; Sun,  4 Aug 2019 04:07:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4D726B0005; Sun,  4 Aug 2019 04:07:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C14266B0006; Sun,  4 Aug 2019 04:07:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 731F86B0003
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 04:07:23 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id f16so39098079wrw.5
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 01:07:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=9iGihd0uQZm0OhWtfPGT4IVKLzhJ/X1+ULeDAnIt+iM=;
        b=W2IR4Ase6goVKDo1L7z/EK1vyHHuOGWwU+qk77f2ekVuvUByLqBOV/vKfrSFmQJd8P
         nWUlkvv9MSJZFKoVqTlWO2IUkf8TNc6L9SzIHU4Oom4vcg/Bya2dHX+YjllSYQ3lJXSw
         myOXhsQFRVq1ZIoM60KYK01C5GIHcRbut1BbfNyOmGApaFZ6LJaUnr8elvtqUibff5hT
         LSY5tZcwPWovB876JZrv87YedDoGp5h8mym+fSKbnE+tG7CVcHDS9gZoHE/pPvoxYqX4
         jJe1zGH+4h3FGabd5A9Bv9QHF+ECsqJeyET7fK3FY/k7DAFlTSjafQG1auZXCixxRwdX
         H4sw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWsBmMP3zhXYEqNnN49VshKA3XnjqAQ73e6/HvyhJytuFn7tkFA
	HXsrQkYAcRbMFJDWMgkh1z9xDFyFA8lmdkFjNi0+aKJtR3g4UQ9N3KlRbaDujSvnXEk5fS7tAxa
	sdk9UUqFmVdZJA3SVFh1Q6mcLTdzsOxIw5byuPugaftAyoQbSgCFDc1tpnOtCxD/Evg==
X-Received: by 2002:a5d:4284:: with SMTP id k4mr150463058wrq.194.1564906042827;
        Sun, 04 Aug 2019 01:07:22 -0700 (PDT)
X-Received: by 2002:a5d:4284:: with SMTP id k4mr150462938wrq.194.1564906041863;
        Sun, 04 Aug 2019 01:07:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564906041; cv=none;
        d=google.com; s=arc-20160816;
        b=wRJjScOeIJ9q/xXBgguQ7KkeZbRJqDD6+H1l1wjcNnoRxUdvxx+WKw3hXbQjq4Q9Qw
         JOcZU9UpF6MI46Gsm75yl8RSvoi24srVJgPvpNlnIUyLuBniM8IGC3ke3U6UUPUkyZUK
         QhWv1aKxaqgUr6tYvGuhogTiCkRPQVvQo+6KbZixyBy7P87weNBfChr4lCXTfdfa9YZw
         1l8TA+4EMqxONR3IpoZ5f3HdM5WzOxGmeT/xhtP1ESFJOhKKwLWb3ekbScNkbLWGTzuu
         f+Prc8+F1FXPtm+9odAZ/8mfjf10QoyAIpkfIbhvSGF6tb/n+X3I+sb+HVi64IDYWgCD
         ZRcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=9iGihd0uQZm0OhWtfPGT4IVKLzhJ/X1+ULeDAnIt+iM=;
        b=Ip5pg35gfB0scSHUFdY4D4QlJlpAT3OPtpnQyRiNSEMn3xvbM255QgsOAaaaEIeOaZ
         TUHaYZ0ZbXjq5xm5SfO4rHV12y5uejxwof/28YOilXqJQKWMl8BymBLmJXZ9/HFoe7c3
         qNM7ReZ+N9Y+XZj9EqCjOuRZ685k4oN4p7P1fbzEA+RnuIMB19H9N2gzrrLM5x+SyVfd
         IFjgrUufY37Z7XV7QJmWP1d/CrM++8WnIIqhfvkPW9bu68lRssvAmPQYgtCQgGmAbKEU
         pcRFC7O7MQi2XRIbOPQbkVeFfw5O7e9b6n+s7A1E5EwYk1wgVMApLCMVaFUjNrbEaPHY
         UgFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q18sor64656204wra.7.2019.08.04.01.07.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 01:07:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwI+gaRAvVddfB9OVUlNyUeUxov9xoEZgkuKZzlqBcvGCZoK4Z/LJM3l40Bq9U3eA5YbA17zQ==
X-Received: by 2002:adf:e2c1:: with SMTP id d1mr163081358wrj.283.1564906041363;
        Sun, 04 Aug 2019 01:07:21 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id r11sm124352644wre.14.2019.08.04.01.07.19
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 01:07:20 -0700 (PDT)
Date: Sun, 4 Aug 2019 04:07:17 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190804040034-mutt-send-email-mst@kernel.org>
References: <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <20190802100414-mutt-send-email-mst@kernel.org>
 <20190802172418.GB11245@ziepe.ca>
 <20190803172944-mutt-send-email-mst@kernel.org>
 <20190804001400.GA25543@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190804001400.GA25543@ziepe.ca>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 03, 2019 at 09:14:00PM -0300, Jason Gunthorpe wrote:
> On Sat, Aug 03, 2019 at 05:36:13PM -0400, Michael S. Tsirkin wrote:
> > On Fri, Aug 02, 2019 at 02:24:18PM -0300, Jason Gunthorpe wrote:
> > > On Fri, Aug 02, 2019 at 10:27:21AM -0400, Michael S. Tsirkin wrote:
> > > > On Fri, Aug 02, 2019 at 09:46:13AM -0300, Jason Gunthorpe wrote:
> > > > > On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
> > > > > > > This must be a proper barrier, like a spinlock, mutex, or
> > > > > > > synchronize_rcu.
> > > > > > 
> > > > > > 
> > > > > > I start with synchronize_rcu() but both you and Michael raise some
> > > > > > concern.
> > > > > 
> > > > > I've also idly wondered if calling synchronize_rcu() under the various
> > > > > mm locks is a deadlock situation.
> > > > > 
> > > > > > Then I try spinlock and mutex:
> > > > > > 
> > > > > > 1) spinlock: add lots of overhead on datapath, this leads 0 performance
> > > > > > improvement.
> > > > > 
> > > > > I think the topic here is correctness not performance improvement
> > > > 
> > > > The topic is whether we should revert
> > > > commit 7f466032dc9 ("vhost: access vq metadata through kernel virtual address")
> > > > 
> > > > or keep it in. The only reason to keep it is performance.
> > > 
> > > Yikes, I'm not sure you can ever win against copy_from_user using
> > > mmu_notifiers?
> > 
> > Ever since copy_from_user started playing with flags (for SMAP) and
> > added speculation barriers there's a chance we can win by accessing
> > memory through the kernel address.
> 
> You think copy_to_user will be more expensive than the minimum two
> atomics required to synchronize with another thread?

I frankly don't know. With SMAP you flip flags twice, and with spectre
you flush the pipeline. Is that cheaper or more expensive than an atomic
operation? Testing is the only way to tell.

> > > Also, why can't this just permanently GUP the pages? In fact, where
> > > does it put_page them anyhow? Worrying that 7f466 adds a get_user page
> > > but does not add a put_page??
> 
> You didn't answer this.. Why not just use GUP?
> 
> Jason

Sorry I misunderstood the question. Permanent GUP breaks lots of
functionality we need such as THP and numa balancing.

release_pages is used instead of put_page.




-- 
MST

