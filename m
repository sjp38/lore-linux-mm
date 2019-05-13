Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2879BC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:46:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8D862084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:46:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8D862084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 973466B0008; Mon, 13 May 2019 12:46:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 921B86B0010; Mon, 13 May 2019 12:46:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 839CB6B0266; Mon, 13 May 2019 12:46:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1D86B0008
	for <linux-mm@kvack.org>; Mon, 13 May 2019 12:46:24 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id r75so1798127pfc.15
        for <linux-mm@kvack.org>; Mon, 13 May 2019 09:46:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=h8MNbl4vAuWZ92K25UarJLhpv5/nwdfbiimru367GCM=;
        b=DLjx2cBThX+YG2bzeZ/pfAcPq4gV0iAc+xOmxfkBX5g1m7WyiDGncHO5asVVLUdgFa
         Phq/Pk7/N33LGiHKTNlddHoswob/UnjnlF2bD/fzjE/qUxYUgHAuaMEzFn0YpY0JewCL
         yz7EKceUDhX64mDjxW/v3GESHnnf3qQmH7Pe7cEqIsfUtUQ/VyvvNdGuhSV7EmrrmlF+
         faDoK+HkDpm1rm87B4tIyDxkQPbmgXsf/CgTrolopSL0Cin5OUqtlseqrf2lWca/AFVM
         PXw0Bnnoc5hXh0cxNJYSc9VDOP9ELs53cZsUL/gkD5RGZ3a95kU0Ij+ul9LAZbpYXsmH
         mBzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWYnPM0VSocA/zUPYFCpmLnrZAkQrE4JXv7M+xigni4b3H7vn7n
	y0+Bi8OzFJ5EuKtcMEIWk1CkYRG/sYzl5TkRR/BFo42caFq31J1SYhUEO6YOOS0CrjKMdLevIIJ
	qd665SBKQDo9ubjIhKJMjfg7sUPMGKRKxg9/UNS2QZPoLzbqefHm0ZFzBL0jNNipX1w==
X-Received: by 2002:a63:d949:: with SMTP id e9mr32090595pgj.437.1557765983963;
        Mon, 13 May 2019 09:46:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXr/Rc3WQhXXdRBxP4CqPXG+k/Pa44mLZBkTkXiquuEzqokNqNlH0zCkxKs9pAQVQe4mBt
X-Received: by 2002:a63:d949:: with SMTP id e9mr32090516pgj.437.1557765983341;
        Mon, 13 May 2019 09:46:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557765983; cv=none;
        d=google.com; s=arc-20160816;
        b=vRcURJMJbWPl3IqPBCPmRDwSEFbkzvgQtpc2ggP1YRKW6fl+H2JRtCsy1plUocqT0F
         BGWQ4mkxY1f/xRQ1M3RjPuAE5z3e9BCn+PhyFmwf9ZA1A2jzDm8d6bYYrDsnXhTAxFiw
         97tCE2KNd0yv6W22FCUzM241q8Mo1jNTiC/oigTu7lPwbs+yD7EwZ3nxpTmSdByP5JTO
         kwD9DL6f7JyslNbqnEHhLp5Q18Tn+hJlF0b++xbO4QImVYZBBQS+KPRcVlkXzTHcEorv
         KHJM6vURZOuUATfo+VH9yQG8C+BdhWYy2DGJkeMHVNpdnxLrT9ZOOdq2Ky3QoCwgekqA
         oP1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=h8MNbl4vAuWZ92K25UarJLhpv5/nwdfbiimru367GCM=;
        b=MQOSdprb86SD9E3dELHqa7bpgvVbJJf+zm2SPUNhZFOSm4p70qNc8dks2eEUyqzFjH
         rhOTMIidrajEknY10qsdHT6Kzd6vn5DRVRxSYx8wz9F3ralG/1g1e5h60VCu5zpI0r3R
         jS6Hdjye2693ktXCuRhAgRCBvr+NKQm8DAKdvRmaLfIbsqTd2zCvGGh/zhj4u2bC+q5W
         U+hBQH3VHkBz+lVY5kV/pS+1VXeC/joi7ljey0u2cC9m+DmnCi2xQGpnpSAjs3P9VdcP
         nagKlWWbipRGPhZIZOqEegsIrNREeYIbE5PMrFrT/k9dP4ZRYOjZUbWqekXSmPjaWRzr
         fG4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id be11si10176029plb.303.2019.05.13.09.46.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 09:46:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of sean.j.christopherson@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 May 2019 09:46:22 -0700
X-ExtLoop1: 1
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.36])
  by orsmga002.jf.intel.com with ESMTP; 13 May 2019 09:46:22 -0700
Date: Mon, 13 May 2019 09:46:22 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>, pbonzini@redhat.com,
	rkrcmar@redhat.com, tglx@linutronix.de, mingo@redhat.com,
	bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com,
	luto@kernel.org, peterz@infradead.org, kvm@vger.kernel.org,
	x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
	liran.alon@oracle.com, jwadams@google.com
Subject: Re: [RFC KVM 19/27] kvm/isolation: initialize the KVM page table
 with core mappings
Message-ID: <20190513164622.GC28561@linux.intel.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-20-git-send-email-alexandre.chartre@oracle.com>
 <a9198e28-abe1-b980-597e-2d82273a2c17@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a9198e28-abe1-b980-597e-2d82273a2c17@intel.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 08:50:19AM -0700, Dave Hansen wrote:
> I seem to remember that the KVM VMENTRY/VMEXIT context is very special.
> Interrupts (and even NMIs?) are disabled.  Would it be feasible to do
> the switching in there so that we never even *get* interrupts in the KVM
> context?

NMIs are enabled on VMX's VM-Exit.  On SVM, NMIs are blocked on exit until
STGI is executed.

