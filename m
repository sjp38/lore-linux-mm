Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F378AC04AB2
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 18:14:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7A39217D7
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 18:14:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="2PD8SaZY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7A39217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AA506B0006; Fri, 10 May 2019 14:14:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55C316B0007; Fri, 10 May 2019 14:14:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 423BD6B0008; Fri, 10 May 2019 14:14:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19F7A6B0006
	for <linux-mm@kvack.org>; Fri, 10 May 2019 14:14:20 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id f92so3347124otb.3
        for <linux-mm@kvack.org>; Fri, 10 May 2019 11:14:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5U30ojrLveO0inIWQQWVEjYKxtRzBkXH88X7bSSzUP8=;
        b=BmSALMutjYgB958VcLiW0GsJybj8BZ6CiR8Il715c6oR1p84SqDVzrL9PYrPksiYgr
         aiPG4yTBu86Ocn/JhLxR/fvom+hUAm3qvHOqcY6MTiP064oIKXeTfJjVMeDJ5+Kr1+YB
         FAv//Z/aLlfQfl3TiGx/EGevyAthTd+QsWXY8V2VZCuh4vZp/POMBXMYUZS9EUGMF4m4
         Dk7YleXYujrjPckGlzDPIf8jJKHGjdNDDBxsdmQcuvP0N6HojDcbdggl3+DttkPM47lY
         tRJxzWP0pW36z3xm3ggpbPiIHIVWvs1KK5Z9aXXzbTaL1zcTCgyonpyCN1Z9IIjimZDW
         DoRA==
X-Gm-Message-State: APjAAAUEpSVaebx2K02SEK89qgrCKpsn9ORHC2DjE0yhAJp2y7zVC2jI
	IplZN4jXpkST5CH1fGBkVFhIuCTMyYYAqsdr8Cbvpsa/Ua+DFyLCIKCKxpniB3CFPNjS+eEeTG5
	aivobryuLX7bVAEIGpCOrALz3NHyFzxIfk+Jty1lWPWW++eOSY23b1knLnOWzugyPEQ==
X-Received: by 2002:aca:f40e:: with SMTP id s14mr856280oih.69.1557512059550;
        Fri, 10 May 2019 11:14:19 -0700 (PDT)
X-Received: by 2002:aca:f40e:: with SMTP id s14mr856249oih.69.1557512059031;
        Fri, 10 May 2019 11:14:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557512059; cv=none;
        d=google.com; s=arc-20160816;
        b=Wr41KtGdx2sLavZ6MqT4FZY6InE7Dtq1pwOA2OBF8P9p9l/f5GH1t+VSIMJheDh+vP
         XaNpiRfYzdWFVs/NDnAUDO+8zmkCJLRNUybx94+8G+GZZUiQgGx71mwon/Kb0bLgL2DX
         LSVDvYdZyJ+xAJZpBIhv+Gqg4jTAvkV+1P7b0RlF8+NZf6vosxBCBGbXPFUDyQQi3mfz
         N6WWIMj0KvjqUb899H1d/6PMYZWaBh+vKIH93gNPp02pCv/YT/ft3KYuAT1VuiyP93O2
         a8fEw6lc7upF0v0vDSHppMB46nAH/sWu6SV8PUJSJ3aZueeoCTt0pjxnwl48mBmGw0xr
         anWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5U30ojrLveO0inIWQQWVEjYKxtRzBkXH88X7bSSzUP8=;
        b=NochmTNz1vmjy/4ebKGGJVcQ1Sbu2v22lZckRkF86R0eiLTUv78Izg4NzXaJMKy8+d
         9Mu2OQ8ky553Yz0+jjmbdHJxpwEvSWzJ5Ot9vltL6H3uU+hDFEYDt6wCfOhOd7W2d+YA
         Vn1MbyCaedyT+ntFXxWxk17iSvhsaeUDIoHjCC/0HOPxBPTwaOoyEUC/LWshJzawnmYr
         nQdkjPpwxxEORhNlt+IffqgSK0dTpnJ7IAXe2nmu1oOGGfgwYDxgmeApswr/u5rjtXib
         JFNAzeezPjosnBVuLVoN8RhZ/+wsRueuI475roR8qFhnbJCBdfMZBHo4BKi4JjD2zEU+
         7txQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=2PD8SaZY;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l25sor3064968otj.173.2019.05.10.11.14.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 11:14:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=2PD8SaZY;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5U30ojrLveO0inIWQQWVEjYKxtRzBkXH88X7bSSzUP8=;
        b=2PD8SaZYjCX5fOspaHLvF+HDNUNfPqOCRXbzBxnlOalcbNSl2AINgSRjHpgf3gU3KY
         Eja3ACdueZfJ9yGmcuCvicELvwx5ByLlYQZuLrKoBdoFf5EWkK5YmRD54TQ2yeglijrs
         U0TTqevIjlZ+fr4h7nBfaBnmlqQ4NdMPc8Qzq73250yzHbW4jSm8kWXZtOrm+d1Wb1Iv
         YaIVtuwhdFPe8UJo0U2VVwLSfpLJD891ErFam1bAQGIXEbu/JkTToR1dLeXCQpfIOMHQ
         zsRCKc2uPrnGdINNn99KF1I7evMFXELfA3gd6MZlkmyfVE+tlUaGD8ZJJADiJp3dyvtt
         TGSA==
X-Google-Smtp-Source: APXvYqzCkRU/LApt95XEDdDEUgIIw7lC4YzebWLylbbCwywX0NVlDoO/rBv9jia1H70b/HmzgSWapfax4U0jRSj8Wlc=
X-Received: by 2002:a9d:6f19:: with SMTP id n25mr2528783otq.367.1557512058405;
 Fri, 10 May 2019 11:14:18 -0700 (PDT)
MIME-Version: 1.0
References: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
 <1557417933-15701-2-git-send-email-larry.bassel@oracle.com> <AT5PR8401MB116928031D52A318F04A2819AB0C0@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
In-Reply-To: <AT5PR8401MB116928031D52A318F04A2819AB0C0@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 10 May 2019 11:14:07 -0700
Message-ID: <CAPcyv4juGEo=sMX01YuqPY9oYDjBjmRp7GvreNnX8YvKQz=SjA@mail.gmail.com>
Subject: Re: [PATCH, RFC 1/2] Add config option to enable FS/DAX PMD sharing
To: "Elliott, Robert (Servers)" <elliott@hpe.com>
Cc: Larry Bassel <larry.bassel@oracle.com>, 
	"mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "willy@infradead.org" <willy@infradead.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 9:32 AM Elliott, Robert (Servers)
<elliott@hpe.com> wrote:
>
>
>
> > -----Original Message-----
> > From: Linux-nvdimm <linux-nvdimm-bounces@lists.01.org> On Behalf Of
> > Larry Bassel
> > Sent: Thursday, May 09, 2019 11:06 AM
> > Subject: [PATCH, RFC 1/2] Add config option to enable FS/DAX PMD
> > sharing
> >
> > If enabled, sharing of FS/DAX PMDs will be attempted.
> >
> ...
> > diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> ...
> >
> > +config MAY_SHARE_FSDAX_PMD
> > +def_bool y
> > +
>
> Is a config option really necessary - is there any reason to
> not choose to do this?

Agree. Either the arch implementation supports it or it doesn't, I
don't see a need for any further configuration flexibility. Seems
ARCH_WANT_HUGE_PMD_SHARE should be renamed ARCH_HAS_HUGE_PMD_SHARE and
then auto-enable it.

