Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 740F2C282D6
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:34:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39BC32184D
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:34:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39BC32184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=il.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF44F8E0002; Wed, 30 Jan 2019 03:34:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA1158E0001; Wed, 30 Jan 2019 03:34:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1C5F8E0002; Wed, 30 Jan 2019 03:34:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 54A768E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:34:16 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id x67so19167789pfk.16
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 00:34:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:in-reply-to:to
         :cc:subject:from:date:references:mime-version:message-id
         :content-transfer-encoding;
        bh=q5cV15IZx65FIyLVhYtwcDBX1O9YB6eb/oMHgiWjsCY=;
        b=bq1Cs8H+LWyB2iResf9j5HjCRz1h1ONFNJT/PYY2qXI8NFhec1yTPTWWiyHNp5xjGv
         QRXYbBnSe8tvw+9wtCROrdRUQSbpJS+YObq3yofAtcPrCTIp6S8ZAMB3OuiOq07TqZpI
         FtAigKuqN80hWTED7zdal+n2gbl6MI5hjro7KtjAPyIake0XOu+QJzicE/nsx1PhyEui
         fND/644Y0ivx/iODDeGK19Uwz6hAYvxYDAzJBFRblqMduAxzipm6ZxI4xoU3KrnyJyi5
         DFKU1qxuSrUkJZHrt+TI2cfWdCRM2d1H2xiPbazLrq0Hi852kiuH3AvAh8/DlPHjE5DK
         6zpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=JOELN@il.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukfA/4yWuQjFUbpPW6+ivkrnVpXj41nMRx2fzSks+DH+zmu3xkbh
	tZU55ccU20+QMhs8h/COxjA3GGVlpkMTorYvmk0GZygxMAK5dyNnXzRBb3/uMLzsKWhGRBmfx4W
	RKOVmJdrJV6I0/WayCYDIgiKw/qydsUaAS5CP3RkCpUzNE0WgeGrkvkMSJfpe3ruDag==
X-Received: by 2002:a17:902:15a8:: with SMTP id m37mr29751955pla.129.1548837256004;
        Wed, 30 Jan 2019 00:34:16 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5F/o/BeKy7tGdceNoS7qYnNXbFVfvHakBo3zmnsq7JSH95MyL5uMS3MlbdMaw+QUYWN/RX
X-Received: by 2002:a17:902:15a8:: with SMTP id m37mr29751931pla.129.1548837255325;
        Wed, 30 Jan 2019 00:34:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548837255; cv=none;
        d=google.com; s=arc-20160816;
        b=XjxtuQ0gl+X8s/1M6BQctkH59WkyvxlRgG/2wEGkNMDyupzkMO4MgZgBa94UzgttM3
         QX0he9uanCm/0sVABWO2h1Kzflt2o0PgQnrKeKrNZ6BklGdCcvAFL4KveTep6U4ZOkNR
         pLUiyCuM519/EY62gbZFKD1vuGA9cEgfEj68bN7G6rlQpDuPUjD0Q8MJL2g0EWL4XPVr
         CxMs2xWqjgsEm+9LCXENVhMTHioh+XE8Dk4vO660Bl+tkLeRl6gqPoA5kLoBCwYmF0fb
         MxuR7wVUn3gmJ90aVeLFdBa0mGb6zzeojZ1KbH2eXuEoq5lWMsQ0FlQErjDa8fAn2wxX
         aIFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:mime-version:references:date
         :from:subject:cc:to:in-reply-to;
        bh=q5cV15IZx65FIyLVhYtwcDBX1O9YB6eb/oMHgiWjsCY=;
        b=U/ZkWKRL0sX1qE8cr7d/UhU6y6azc/mnZHV439FksVSjOIVzWPM6wF9KwD+MW0+mf2
         JWt6W/H5ABqPPXhv3AW1jAtt9PayfA56rU2c0aEtsNvafweFW7lOsuTl4qB/Yj282Grd
         9u/jUdkBw/n54OCVMobLG65rFQ2LuC32vLWQukQY8zvQ+08OHx3/els/3T3ZTob6AwAX
         fEoSxDMPiMYDtvtx8tR+fqSmfPhHxC4iCe9RW7w9j+6sZST8E4GoU6t74/S/kpN31wSe
         O539U0EyZLwC26mfd45hzw8nMRlW4bWmWWGQLqUJK8rP+DeUFRevMaTNBoTp+cu63MkF
         jHJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=JOELN@il.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u22si848809pgk.335.2019.01.30.00.34.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 00:34:15 -0800 (PST)
Received-SPF: pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=JOELN@il.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0U8XnSd037502
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:34:14 -0500
Received: from smtp.notes.na.collabserv.com (smtp.notes.na.collabserv.com [192.155.248.91])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qb8avgk1e-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:34:14 -0500
Received: from localhost
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <linux-mm@kvack.org> from <JOELN@il.ibm.com>;
	Wed, 30 Jan 2019 08:34:13 -0000
Received: from us1a3-smtp03.a3.dal06.isc4sb.com (10.106.154.98)
	by smtp.notes.na.collabserv.com (10.106.227.143) with smtp.notes.na.collabserv.com ESMTP;
	Wed, 30 Jan 2019 08:34:05 -0000
Received: from us1a3-mail108.a3.dal06.isc4sb.com ([10.146.45.126])
          by us1a3-smtp03.a3.dal06.isc4sb.com
          with ESMTP id 2019013008340388-215235 ;
          Wed, 30 Jan 2019 08:34:03 +0000 
In-Reply-To: <20190129170406.GD10094@ziepe.ca>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Doug Ledford <dledford@redhat.com>, Leon Romanovsky
 <leon@kernel.org>,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-rdma@vger.kernel.org, linux-rdma-owner@vger.kernel.org,
        Mike
 Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 5/5] RDMA/uverbs: add UVERBS_METHOD_REG_REMOTE_MR
From: "Joel Nider" <JOELN@il.ibm.com>
Date: Wed, 30 Jan 2019 10:34:02 +0200
References: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
 <1548768386-28289-6-git-send-email-joeln@il.ibm.com>
 <20190129170406.GD10094@ziepe.ca>
MIME-Version: 1.0
X-KeepSent: 8090F111:AEB0B591-C2258392:002E4215;
 type=4; name=$KeepSent
X-Mailer: IBM Notes Release 9.0.1FP7 August 18, 2016
X-LLNOutbound: False
X-Disclaimed: 46851
X-TNEFEvaluated: 1
x-cbid: 19013008-9951-0000-0000-00000B265F7C
X-IBM-SpamModules-Scores: BY=0; FL=0; FP=0; FZ=0; HX=0; KW=0; PH=0;
 SC=0.425523; ST=0; TS=0; UL=0; ISC=; MB=0.000759
X-IBM-SpamModules-Versions: BY=3.00010503; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000277; SDB=6.01153831; UDB=6.00601589; IPR=6.00934206;
 BA=6.00006216; NDR=6.00000001; ZLA=6.00000005; ZF=6.00000009; ZB=6.00000000;
 ZP=6.00000000; ZH=6.00000000; ZU=6.00000002; MB=3.00025352; XFM=3.00000015;
 UTC=2019-01-30 08:34:10
X-IBM-AV-DETECTION: SAVI=unsuspicious REMOTE=unsuspicious XFE=unused
X-IBM-AV-VERSION: SAVI=2019-01-30 05:59:00 - 6.00009527
x-cbparentid: 19013008-9952-0000-0000-00001B34A862
Message-Id: <OF8090F111.AEB0B591-ONC2258392.002E4215-C2258392.002F0FDE@notes.na.collabserv.com>
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-30_07:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

linux-rdma-owner@vger.kernel.org wrote on 01/29/2019 07:04:06 PM:

> On Tue, Jan 29, 2019 at 03:26:26PM +0200, Joel Nider wrote:
> > Add a new handler for new uverb reg=5Fremote=5Fmr. The purpose is to=20
register
> > a memory region in a different address space (i.e. process) than the
> > caller.
> >=20
> > The main use case which motivated this change is post-copy container
> > migration. When a migration manager (i.e. CRIU) starts a migration, it
> > must have an open connection for handling any page faults that occur
> > in the container after restoration on the target machine. Even though
> > CRIU establishes and maintains the connection, ultimately the memory
> > is copied from the container being migrated (i.e. a remote address
> > space). This container must remain passive -- meaning it cannot have
> > any knowledge of the RDMA connection; therefore the migration manager
> > must have the ability to register a remote memory region. This remote
> > memory region will serve as the source for any memory pages that must
> > be copied (on-demand or otherwise) during the migration.
> >=20
> > Signed-off-by: Joel Nider <joeln@il.ibm.com>
> >  drivers/infiniband/core/uverbs=5Fstd=5Ftypes=5Fmr.c | 129=20
+++++++++++++++++++++++++-
> >  include/rdma/ib=5Fverbs.h                       |   8 ++
> >  include/uapi/rdma/ib=5Fuser=5Fioctl=5Fcmds.h        |  13 +++
> >  3 files changed, 149 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/drivers/infiniband/core/uverbs=5Fstd=5Ftypes=5Fmr.c b/driv=
ers/
> infiniband/core/uverbs=5Fstd=5Ftypes=5Fmr.c
> > index 4d4be0c..bf7b4b2 100644
> > +++ b/drivers/infiniband/core/uverbs=5Fstd=5Ftypes=5Fmr.c
> > @@ -150,6 +150,99 @@ static int=20
UVERBS=5FHANDLER(UVERBS=5FMETHOD=5FDM=5FMR=5FREG)(
> >     return ret;
> >  }
> >=20
> > +static int UVERBS=5FHANDLER(UVERBS=5FMETHOD=5FREG=5FREMOTE=5FMR)(
> > +   struct uverbs=5Fattr=5Fbundle *attrs)
> > +{
>=20
> I think this should just be REG=5FMR with an optional remote PID
> argument

Maybe I missed something.  Isn't REG=5FMR only implemented as a write()=20
command? In our earlier conversation you told me all new commands must be=20
implemented as ioctl() commands.


> >  DECLARE=5FUVERBS=5FNAMED=5FOBJECT(
> >     UVERBS=5FOBJECT=5FMR,
> >     UVERBS=5FTYPE=5FALLOC=5FIDR(uverbs=5Ffree=5Fmr),
> >     &UVERBS=5FMETHOD(UVERBS=5FMETHOD=5FDM=5FMR=5FREG),
> >     &UVERBS=5FMETHOD(UVERBS=5FMETHOD=5FMR=5FDESTROY),
> > -   &UVERBS=5FMETHOD(UVERBS=5FMETHOD=5FADVISE=5FMR));
> > +   &UVERBS=5FMETHOD(UVERBS=5FMETHOD=5FADVISE=5FMR),
> > +   &UVERBS=5FMETHOD(UVERBS=5FMETHOD=5FREG=5FREMOTE=5FMR),
> > +);
>=20
> I'm kind of surprised this compiles with the trailing comma?
Personally, I think it is nicer with the trailing comma. Of course=20
syntactically it makes no sense, but when adding a new entry, you don't=20
have to touch the previous line, which makes the diff cleaner. If this is=20
against standard practices I will remove the comma.



