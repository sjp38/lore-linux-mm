Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43CCCC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:36:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 027EA222A7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:36:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 027EA222A7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADEBE8E010E; Mon, 11 Feb 2019 12:36:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB4838E0108; Mon, 11 Feb 2019 12:36:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CAF78E010E; Mon, 11 Feb 2019 12:36:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7275C8E0108
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:36:17 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 42so13494338qtr.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:36:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=5vEPqKUiunV98ITCvzYpEkjcwq843GMOIN144suOLbs=;
        b=VRYmTBrmuqjA/Fn3jnW8BQhZGeD0t2Z17VoLNZ7FG9hAiYFOIWYymvyZSOWYbVFkYx
         5KZKXgpPdOXtx1zgkFv3Or0jtVii3QsATanOhm2fcNVs/PGA7q2MXUweAYOmIMzFz72I
         Zjx2uX3r0w25Ktib3PGKs0RAwZ30RkuCZW6TDDti5d12m+9m5ya+FohmnDb/RdvHNESs
         Ymz6hOEOFng51wEAXSPCwxdxTOy2tG2y1eyJWFU8NL+ecRx4hPOO+7FRc9CmgEcXOmwP
         QgmcsvvuLE5lH2dsf+A8S0Z0QywOzvzI8H25j+iiGIOjq4d1GGwJtDFYCL/kOIXnpoez
         1VDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYIcVmIyJ0PtzBkU90tmNbnQP7JV8c5eBcS0TgEeewSIOhMjjJz
	nRpRqvQtOy76oi6bA6JuI7Dh+mKnUhfI5tH3G25jKGfkuwOWZ+VgLnzmd5wdLgEWRxmEFbGoFiB
	DzhGLg39dnlXvGfwBSkt4WQbTJ8heMnjuuhKn6c9fnn6Zg2ILP24joinsBzLS+Czqyw==
X-Received: by 2002:ac8:34d7:: with SMTP id x23mr13008564qtb.100.1549906577127;
        Mon, 11 Feb 2019 09:36:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYhchyMFoz3N3idKXb0bmEt4EOA6grhFCpw0V//w6FXhPL9AcpWAMGsa00ZNH4FPlHBqhEi
X-Received: by 2002:ac8:34d7:: with SMTP id x23mr13008528qtb.100.1549906576493;
        Mon, 11 Feb 2019 09:36:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549906576; cv=none;
        d=google.com; s=arc-20160816;
        b=ZCJgfDos3Fpgb1kKbGtmAWKq47PImB7w13olEIn52YiAieXZOXu85ay/lx61gFjfk2
         T8iaIzDufrMZN51n/EC7FOZLes+sRrM/fuaLK9zzBxqUs//A8DrUrEvJBrsgTrO8owXu
         wONviLtCD96ka4WY1dAIplaO8EtYIo+iw113bO8D8IGX+H4YzslEJpx8ZiN+B40caSrK
         ayGdw+tNwdFV9/G/bR1eB9uNPB4kslv/NQCcReqZRgFjdNK+NdHlhd8nBO0jhiyCCgqA
         MQgK5r62d5B+e3Hyo9I1eV107AGdXKHiTi92FRaGcAiTYJ7xKZ2S+dkOQxdTIRTMBcLd
         vfIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=5vEPqKUiunV98ITCvzYpEkjcwq843GMOIN144suOLbs=;
        b=syauRSNRswBquOUGVV/zvlFkqYBOj24QF8MVthW85VPCqbiJyu4MB0aMQE18GqZYHJ
         P173Hp9DjnNhsogX50LlY2zgRLwYS+km1lRkeTcViIBd4Hnnd8EH7hCHP9kHCnBHjXPl
         kMOlc4i0HeI6520cdRa/ypF9S3dGqid/y7tL/svZV85Z6x3T8jN7NdIfTMh7upw3HvMD
         gBkPQ5kAFOdBoUvZUugdhknnxnDwzYq1D5rSrIHzPMme3iv1on4uVYSl+az8lpJEqrnl
         I3lbuVKVMeFz0GlhnuLxvpiSB+6jIDvOyRkymSZi6J9TE6rQulljxXpG/eZMAmFkSGbE
         06EA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t64si7205025qkf.154.2019.02.11.09.36.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 09:36:16 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8CE58C04BE02;
	Mon, 11 Feb 2019 17:36:15 +0000 (UTC)
Received: from redhat.com (ovpn-120-40.rdu2.redhat.com [10.10.120.40])
	by smtp.corp.redhat.com (Postfix) with SMTP id A4D292C8DE;
	Mon, 11 Feb 2019 17:36:13 +0000 (UTC)
Date: Mon, 11 Feb 2019 12:36:13 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de,
	hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
	akpm@linux-foundation.org
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory hints
Message-ID: <20190211122321-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181552.12095.46287.stgit@localhost.localdomain>
 <20190209194437-mutt-send-email-mst@kernel.org>
 <869a170e9232ffbc8ddbcf3d15535e8c6daedbde.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <869a170e9232ffbc8ddbcf3d15535e8c6daedbde.camel@linux.intel.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Mon, 11 Feb 2019 17:36:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 08:31:34AM -0800, Alexander Duyck wrote:
> On Sat, 2019-02-09 at 19:49 -0500, Michael S. Tsirkin wrote:
> > On Mon, Feb 04, 2019 at 10:15:52AM -0800, Alexander Duyck wrote:
> > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > 
> > > Add guest support for providing free memory hints to the KVM hypervisor for
> > > freed pages huge TLB size or larger. I am restricting the size to
> > > huge TLB order and larger because the hypercalls are too expensive to be
> > > performing one per 4K page.
> > 
> > Even 2M pages start to get expensive with a TB guest.
> 
> Agreed.
> 
> > Really it seems we want a virtio ring so we can pass a batch of these.
> > E.g. 256 entries, 2M each - that's more like it.
> 
> The only issue I see with doing that is that we then have to defer the
> freeing. Doing that is going to introduce issues in the guest as we are
> going to have pages going unused for some period of time while we wait
> for the hint to complete, and we cannot just pull said pages back. I'm
> not really a fan of the asynchronous nature of Nitesh's patches for
> this reason.

Well nothing prevents us from doing an extra exit to the hypervisor if
we want. The asynchronous nature is there as an optimization
to allow hypervisor to do its thing on a separate CPU.
Why not proceed doing other things meanwhile?
And if the reason is that we are short on memory, then
maybe we should be less aggressive in hinting?

E.g. if we just have 2 pages:

hint page 1
page 1 hint processed?
	yes - proceed to page 2
	no - wait for interrupt

get interrupt that page 1 hint is processed
hint page 2


If hypervisor happens to be running on same CPU it
can process things synchronously and we never enter
the no branch.





> > > Using the huge TLB order became the obvious
> > > choice for the order to use as it allows us to avoid fragmentation of higher
> > > order memory on the host.
> > > 
> > > I have limited the functionality so that it doesn't work when page
> > > poisoning is enabled. I did this because a write to the page after doing an
> > > MADV_DONTNEED would effectively negate the hint, so it would be wasting
> > > cycles to do so.
> > 
> > Again that's leaking host implementation detail into guest interface.
> > 
> > We are giving guest page hints to host that makes sense,
> > weird interactions with other features due to host
> > implementation details should be handled by host.
> 
> I don't view this as a host implementation detail, this is guest
> feature making use of all pages for debugging. If we are placing poison
> values in the page then I wouldn't consider them an unused page, it is
> being actively used to store the poison value.

Well I guess it's a valid point of view for a kernel hacker, but they are
unused from application's point of view.
However poisoning is transparent to users and most distro users
are not aware of it going on. They just know that debug kernels
are slower.
User loading a debug kernel and immediately breaking overcommit
is an unpleasant experience.

> If we can achieve this
> and free the page back to the host then even better, but until the
> features can coexist we should not use the page hinting while page
> poisoning is enabled.

Existing hinting in balloon allows them to coexist so I think we
need to set the bar just as high for any new variant.

> This is one of the reasons why I was opposed to just disabling page
> poisoning when this feature was enabled in Nitesh's patches. If the
> guest has page poisoning enabled it is doing something with the page.
> It shouldn't be prevented from doing that because the host wants to
> have the option to free the pages.

I agree but I think the decision belongs on the host. I.e.
hint the page but tell the host it needs to be careful
about the poison value. It might also mean we
need to make sure poisoning happens after the hinting, not before.

-- 
MST

