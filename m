Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EE51C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 23:55:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A22872073F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 23:55:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="MBKpvprF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A22872073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05B808E0065; Thu,  7 Feb 2019 18:55:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0312B8E0002; Thu,  7 Feb 2019 18:55:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E890A8E0065; Thu,  7 Feb 2019 18:55:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id B9FF38E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 18:55:12 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id d5so1455356otl.21
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 15:55:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wuu6aq9mmWRYWmAEazq1JML050O5p2LjZKSNRxmlZ5g=;
        b=SdAUHYVKK8TFOHMu2z7QKjEtjFX7bhQFsmDM8WKhuh6Bq70mKFmIdxuHJs5PWgKhJp
         3HFAUvYLiSA1pPPHl4BE7p6wAEhfM2Cw3knZmaJ+kCIe0pDlWEGWQEnbThMqrg4bqBYP
         JAxWn7p2lc9VXKAC51hzbVlfjYkQnylhiUApkzbrjlpMLTRiVfD1uQEwWQCCsvmQgK/V
         UGNlxH1MLi7hKRwWjOY7qLBdf14po0zrCu47f5HTTTtlhdjyOHHDNkTavf1TBbLdhTek
         FIDHkRcnS5me1Az4rxbZ+pXBZjEmCDfUOGNMXyqpmepAz6CDgUMeArG+/8z5hOaE6IyM
         sMXA==
X-Gm-Message-State: AHQUAuZsUthRR52ZrS6pBZ729DRqbCT0gyFWD5U2Chb9jvxEPqzAvYaR
	471LGXCGkyNQz8yiTkzXg9fVAB1PfYaLoW9FPUMZbpFcCAQSIz8AC2WbgqAyxBEdzVzzv5FD6KX
	9HCnFHv64anLfGO8IFGMbu+tKlOfc7IEUWzzfd5bLUk6ZiFl9PL5YIAo6yh/hZvUN4tcLFZGH4F
	WF4ofu1by3YAKmdsiKJXcRhDBe0Irmego3DhrJR58/wZW63wMddPK7uKFKRw72IFoZjEDgsNqDs
	n47+WvNsyqUeCTLe9gR1WZ2S6nVu73jZYDo8hb4XhWXrFzCbk0qPhdGV9X5WeISlWa1bH6Mlc5u
	5ecdnjb+1QU+uE3Dg6QFLLc35C1Reahl+mpzXq+7I4RY6giU8wsFQ6dyi2+A8/U/jwXQyjw9E7M
	Z
X-Received: by 2002:a9d:3426:: with SMTP id v35mr11103506otb.71.1549583712348;
        Thu, 07 Feb 2019 15:55:12 -0800 (PST)
X-Received: by 2002:a9d:3426:: with SMTP id v35mr11103475otb.71.1549583711277;
        Thu, 07 Feb 2019 15:55:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549583711; cv=none;
        d=google.com; s=arc-20160816;
        b=GzZkDx8lQIt3E8DLrL5rsbe2PGQrISprG1xys2PmevKCoC6g00bQkZeqZ869lYUj6u
         BwSyIqI9rHTbU5eCBZOpM4HtsCla5U4zcsMKGoPSmubUXHxCFfRn4ZPyyDCXjfC4Iljg
         bFcqGzMnPbnx1asH69C2V07IbgdYQZVNOHauP7AATnCn4ocNi26av5XF3xLvchORe6WR
         Ko2ria/NgXoCHXOZTI6iqBYGq7LdeT4LY2degaCNj4LgdTJWDJUYxlNiY/BipuB9HUpx
         +c6JgES621/tY9nhCgRdAGq72rzF+7yf29ofcA0UCxa8DJgLnBUfuMV/b+9HXlrUMZMq
         cROw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wuu6aq9mmWRYWmAEazq1JML050O5p2LjZKSNRxmlZ5g=;
        b=QW5UJqVtbTwGEJbGHDAeKqPMYu4cIQajojiCzDMhdrd3Ai5K/xi0wSQkuuxSuMZRAb
         LGBVI8SiWl/dcKTn8hYF5AzswUCKeN/q6k0hXJYBSrj8pCjiCdZWFroCI3e6jVCNJymB
         CIJSWB+XGYy7npIRAlbNqBfQkrMDSgBZnc1luqK+tFT3LslVO57dL91ahHhvThnTGvzE
         WbfyQg/kXHfVU25a4RRZaJ7x7JPejsn/vcihXfseL+q2iFxhU8/FDAcYipgJcWnHybfm
         DZ2GDdSuOJzSxU2YnWWffP/gr6WrDlqclN7D+lDAGKLSDczbAVz7X9aRsf1JQ8xlJlg5
         7eRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=MBKpvprF;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m186sor236643oif.18.2019.02.07.15.55.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 15:55:10 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=MBKpvprF;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wuu6aq9mmWRYWmAEazq1JML050O5p2LjZKSNRxmlZ5g=;
        b=MBKpvprFNpUeQahrEAvcOhuvzE9JE1qn2cKGX+VcKhcGtTobMfAmsZHUqRosEFLgcs
         mUqGl2rU8gYhn58O9a908me5vTVjFFGAfQi7TJBEt1u5hthVkL/IBwBYkG8QGHavMv8v
         ZrM6I2Q60JVT2472qVlfoyUN2Cl+F0oNcqv40BYzXTZ1aPQ0yJ4Dx9Mrq5snGjsLeRJv
         oTchGkY7jc1FbVrvqWXby6kjlGBLq++/dOIKprajKwmudG/Ui/megC5gKXO7eoQdI3N4
         i5K9KVEKGofchk7sR1CxW6njled2+6eTYcpKR4WTWK/hPnW7phTQzJOnyC6L+tr7mzwz
         puGQ==
X-Google-Smtp-Source: AHgI3IZ8oLiizk9A/wsiEDpzUAkAIj/Y5hRLuqUsFLgj6eBrY8gxGnGq1NPBw/Sw9Tz5Pq4ry68pvu7qyEBchCDRBPc=
X-Received: by 2002:a05:6808:344:: with SMTP id j4mr397968oie.149.1549583710509;
 Thu, 07 Feb 2019 15:55:10 -0800 (PST)
MIME-Version: 1.0
References: <20190206173114.GB12227@ziepe.ca> <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <20190207035258.GD6173@dastard> <20190207052310.GA22726@ziepe.ca>
 <CAPcyv4jd4gxvt3faYYRbv5gkc6NGOKjY_Z-P0Ph=ss=gWZw7sA@mail.gmail.com> <20190207171736.GD22726@ziepe.ca>
In-Reply-To: <20190207171736.GD22726@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 7 Feb 2019 15:54:58 -0800
Message-ID: <CAPcyv4hsHeCGjcJNEmMg_6FYEsQ_8Z=bvx+WmO1v_LmoXbJrxA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dave Chinner <david@fromorbit.com>, Doug Ledford <dledford@redhat.com>, 
	Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org, 
	linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, 
	Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 7, 2019 at 9:17 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Wed, Feb 06, 2019 at 10:00:28PM -0800, Dan Williams wrote:
>
> > > > If your argument is that "existing RDMA apps don't have a recall
> > > > mechanism" then that's what they are going to need to implement to
> > > > work with DAX+RDMA. Reliable remote access arbitration is required
> > > > for DAX+RDMA, regardless of what filesysetm the data is hosted on.
> > >
> > > My argument is that is a toy configuration that no production user
> > > would use. It either has the ability to wait for the lease to revoke
> > > 'forever' without consequence or the application will be critically
> > > de-stablized by the kernel's escalation to time bound the response.
> > > (or production systems never get revoke)
> >
> > I think we're off track on the need for leases for anything other than
> > non-ODP hardware.
> >
> > Otherwise this argument seems to be saying there is absolutely no safe
> > way to recall a memory registration from hardware, which does not make
> > sense because SIGKILL needs to work as a last resort.
>
> SIGKILL destroys all the process's resources. This is supported.
>
> You are asking for some way to do a targeted *disablement* (we can't
> do destroy) of a single resource.
>
> There is an optional operation that could do what you want
> 'rereg_user_mr'- however only 3 out of 17 drivers implement it, one of
> those drivers supports ODP, and one is supporting old hardware nearing
> its end of life.
>
> Of the two that are left, it looks like you might be able to use
> IB_MR_REREG_PD to basically disable the MR. Maybe. The spec for this
> API is not as a fence - the application is supposed to quiet traffic
> before invoking it. So even if it did work, it may not be synchronous
> enough to be safe for DAX.
>
> But lets imagine the one driver where this is relavents gets updated
> FW that makes this into a fence..
>
> Then the application's communication would more or less explode in a
> very strange and unexpected way, but perhaps it could learn to put the
> pieces back together, reconnect and restart from scratch.
>
> So, we could imagine doing something here, but it requires things we
> don't have, more standardization, and drivers to implement new
> functionality. This is not likely to happen.
>
> Thus any lease mechanism is essentially stuck with SIGKILL as the
> escalation.
>
> > > The arguing here is that there is certainly a subset of people that
> > > don't want to use ODP. If we tell them a hard 'no' then the
> > > conversation is done.
> >
> > Again, SIGKILL must work the RDMA target can't survive that, so it's
> > not impossible, or are you saying not even SIGKILL can guarantee an
> > RDMA registration goes idle? Then I can see that "hard no" having real
> > teeth otherwise it's a matter of software.
>
> Resorting to SIGKILL makes this into a toy, no real production user
> would operate in that world.
>
> > > I don't like the idea of building toy leases just for this one,
> > > arguably baroque, case.
> >
> > What makes it a toy and baroque? Outside of RDMA registrations being
> > irretrievable I have a gap in my understanding of what makes this
> > pointless to even attempt?
>
> Insisting to run RDMA & DAX without ODP and building an elaborate
> revoke mechanism to support non-ODP HW is inherently baroque.
>
> Use the HW that supports ODP.
>
> Since no HW can do disable of a MR, the escalation path is SIGKILL
> which makes it a non-production toy.
>
> What you keep missing is that for people doing this - the RDMA is a
> critical compoment of the system, you can't just say the kernel will
> randomly degrade/kill RDMA processes - that is a 'toy' configuration
> that is not production worthy.
>
> Especially since this revoke idea is basically a DOS engine for the
> RDMA protocol if another process can do actions to trigger revoke. Now
> we have a new class of security problems. (again, screams non
> production toy)
>
> The only production worthy way is to have the FS be a partner in
> making this work without requiring revoke, so the critical RDMA
> traffic can operate safely.
>
> Otherwise we need to stick to ODP.

Thanks for this it clears a lot of things up for me...

...but this statement:

> The only production worthy way is to have the FS be a partner in
> making this work without requiring revoke, so the critical RDMA
> traffic can operate safely.

...belies a path forward. Just swap out "FS be a partner" with "system
administrator be a partner". In other words, If the RDMA stack can't
tolerate an MR being disabled then the administrator needs to actively
disable the paths that would trigger it. Turn off reflink, don't
truncate, avoid any future FS feature that might generate unwanted
lease breaks. We would need to make sure that lease notifications
include the information to identify the lease breaker to debug escapes
that might happen, but it is a solution that can be qualified to not
lease break. In any event, this lets end users pick their filesystem
(modulo RDMA incompatible features), provides an enumeration of lease
break sources in the kernel, and opens up FS-DAX to a wider array of
RDMA adapters. In general this is what Linux has historically done,
give end users technology freedom.

