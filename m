Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0529BC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 06:28:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C727C20B1F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 06:28:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C727C20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 626B36B0003; Mon,  5 Aug 2019 02:28:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D7996B0005; Mon,  5 Aug 2019 02:28:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C65F6B0006; Mon,  5 Aug 2019 02:28:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2BF306B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 02:28:24 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e32so74738388qtc.7
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 23:28:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=KWA/zRel4261JwzY6PT0mEAQMawH9MJ6QOovbW+PtWw=;
        b=KCsRCe7xv/MGNshCxOPfWo+yAi4TZJqGSvB2S5LKI6RFotXn/kGg2KBfIDLNara/78
         PsErmJAS/aJOa6dfglIfuwCy0i5zSsi9h3rJBEBAAmxOFp4qKjmed+My2Kwe3Ef7/57a
         7IveAM2APNTECX1fO3wZz65KvcqoZoHpeQrYATq8rDxXd+fOzby+fB+v3YJBT00qpTNA
         25iBpYQ3JqArmCP9l8qLFV33+GabDD501VMmlIzgHrPKcpp46A6VmtS9Jvf0LWHSdqSf
         9xHlXO4FhDhkbH2AyjptIZpt+5cdr6e3moxjwsYbj0BMZCTPBgXfutx/+Nx1+qzr0BFk
         T0UQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXo0xzsSfGXHjyyi7gO3giNrhEG0HnjYk3yzjVa9XRWJrLVjmu4
	TaTTXXKHK/MARRxwBmv2ERGUyNi9kwaKUQjk+sPCv9pbJQXXrhDNqlfcc1+4kGTywwXRpXKtmeX
	MrfeNIFRkdvfN2Np8K8zhYYv0dURsRx6hxznzWbISTAoMtvj5OqmVe4bXzcjU4+pMQg==
X-Received: by 2002:a0c:c107:: with SMTP id f7mr13324791qvh.150.1564986503916;
        Sun, 04 Aug 2019 23:28:23 -0700 (PDT)
X-Received: by 2002:a0c:c107:: with SMTP id f7mr13324764qvh.150.1564986503175;
        Sun, 04 Aug 2019 23:28:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564986503; cv=none;
        d=google.com; s=arc-20160816;
        b=DliCQI2xDesfbPZMKdYAcq+MOj+Olfmpg1AYGVGnl464TSTDZAnKiUQIy0qH1Y/AWr
         JyYq/SbgBV+/I841TBwAEuZg5PdYpjk6aOzLxvW/ghYGshcgW+VRLsIMYOb06dZLBHAE
         Y8Z5bpTLrlePXp//1xujrcNC4/vszeKq3eTrt4017i6FqhCUFtnAWtqZLlTruzroZ/7J
         rEsmqny1Q9CNHMiopH28/hhjbxkv1ErCoQDkJefbePmvhjx6uih8bBOodhxWbN+pLSC6
         uZXY+RgJeRbKZXXl902vIeao9zVoFe2W/qgvlkYVC+YF+MwbvxkLlYXBC+yJ7wUUJZ4z
         A7HQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=KWA/zRel4261JwzY6PT0mEAQMawH9MJ6QOovbW+PtWw=;
        b=PgmJbd5O95Z58D8EJbNT7dqui9oD+GVQr3Y6MOuVDf9EPMRv1V3sD/NXjEBWVCEotW
         Eg3RcRcyRfdBzW+NGu9dMBatviPSX3b0pIDQNt2FpbuSZrnV4EsB65d6xdttXD1gnQb0
         yRepN/T/iaPeXZyW1YC1E5JmxKQuduM0UNDXAUZZsz4dABNmxc6xgsXcE2PyZ634+MjV
         KDxFrhfl1+E25Nx7WFkqu1lKlPC3CWNsRtEPbIk17OfI6HRzmDK4MTXg9KOaqa282KaH
         MElSJDAlECg5juEDAAetaffWPp5jXkAais2bBL6eaveICLovHzCfh4Eq8CUAaOP+rl4F
         s/YQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d14sor70603390qvd.66.2019.08.04.23.28.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 23:28:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxmlaPhRV6WcTX7MFxiXlbHz2huG6EImOc41/XnvtSvCJPv0MiUiy9pupzwZ++qXjlc9yUxxA==
X-Received: by 2002:ad4:4a14:: with SMTP id m20mr5317024qvz.58.1564986502769;
        Sun, 04 Aug 2019 23:28:22 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id q56sm42239382qtq.64.2019.08.04.23.28.19
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 23:28:21 -0700 (PDT)
Date: Mon, 5 Aug 2019 02:28:16 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190805020752-mutt-send-email-mst@kernel.org>
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com>
 <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802094331-mutt-send-email-mst@kernel.org>
 <6c3a0a1c-ce87-907b-7bc8-ec41bf9056d8@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <6c3a0a1c-ce87-907b-7bc8-ec41bf9056d8@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 12:33:45PM +0800, Jason Wang wrote:
> 
> On 2019/8/2 下午10:03, Michael S. Tsirkin wrote:
> > On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
> > > Btw, I come up another idea, that is to disable preemption when vhost thread
> > > need to access the memory. Then register preempt notifier and if vhost
> > > thread is preempted, we're sure no one will access the memory and can do the
> > > cleanup.
> > Great, more notifiers :(
> > 
> > Maybe can live with
> > 1- disable preemption while using the cached pointer
> > 2- teach vhost to recover from memory access failures,
> >     by switching to regular from/to user path
> 
> 
> I don't get this, I believe we want to recover from regular from/to user
> path, isn't it?

That (disable copy to/from user completely) would be a nice to have
since it would reduce the attack surface of the driver, but e.g. your
code already doesn't do that.



> 
> > 
> > So if you want to try that, fine since it's a step in
> > the right direction.
> > 
> > But I think fundamentally it's not what we want to do long term.
> 
> 
> Yes.
> 
> 
> > 
> > It's always been a fundamental problem with this patch series that only
> > metadata is accessed through a direct pointer.
> > 
> > The difference in ways you handle metadata and data is what is
> > now coming and messing everything up.
> 
> 
> I do propose soemthing like this in the past:
> https://www.spinics.net/lists/linux-virtualization/msg36824.html. But looks
> like you have some concern about its locality.

Right and it doesn't go away. You'll need to come up
with a test that messes it up and triggers a worst-case
scenario, so we can measure how bad is that worst-case.

> But the problem still there, GUP can do page fault, so still need to
> synchronize it with MMU notifiers.

I think the idea was, if GUP would need a pagefault, don't
do a GUP and do to/from user instead. Hopefully that
will fault the page in and the next access will go through.

> The solution might be something like
> moving GUP to a dedicated kind of vhost work.

Right, generally GUP.

> 
> > 
> > So if continuing the direct map approach,
> > what is needed is a cache of mapped VM memory, then on a cache miss
> > we'd queue work along the lines of 1-2 above.
> > 
> > That's one direction to take. Another one is to give up on that and
> > write our own version of uaccess macros.  Add a "high security" flag to
> > the vhost module and if not active use these for userspace memory
> > access.
> 
> 
> Or using SET_BACKEND_FEATURES?

No, I don't think it's considered best practice to allow unpriveledged
userspace control over whether kernel enables security features.

> But do you mean permanent GUP as I did in
> original RFC https://lkml.org/lkml/2018/12/13/218?
> 
> Thanks

Permanent GUP breaks THP and NUMA.

> > 
> > 

