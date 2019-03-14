Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,MIME_HTML_ONLY,
	SPF_PASS,T_KAM_HTML_FONT_INVALID autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86321C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 12:31:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F366206BA
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 12:31:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=e.atlantisthepalm.com header.i=info@e.atlantisthepalm.com header.b="0N8FFe5K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F366206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=e.atlantisthepalm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 180598E0003; Thu, 14 Mar 2019 08:31:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10B168E0001; Thu, 14 Mar 2019 08:31:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEA578E0003; Thu, 14 Mar 2019 08:31:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 65ECB8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 08:31:37 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id b9so2259054wrw.14
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 05:31:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:errors-to:message-id
         :list-unsubscribe:mime-version:from:to:date:subject
         :content-transfer-encoding;
        bh=Ci/uaxv9SHgTeRXd9jOpvr/sP/RkeJ7ywDtAhRBjvQM=;
        b=pHqpI/481B3x227zG+ZWEfZbB8HnZcSLxpvTTZdU4EBEyMphEEiTRCwIjZSdZCLK8H
         B08cLh7+CQIXgw1t7M49PrMN0vRkT7GA5p6kW2C3qFY9pnSt28BltcYVH0o32tyqnFKA
         ndD6sCFN8l78jCGRgwJIfoLNksIXu8Q3LbdbWmZef5OpAwU1eblQpk16vBqVz3qlzIpZ
         9WwfdSGzKuQsPEXl91AKQ26D0MEIsWcTwr+SLYODGt/7tNE5E7WpqtCJccx8z43Pnv67
         vVf2IuKyy0UX9zgjZNgfGcO1dhi5idVmcIQFNJ82iOZtCtS3p4+04Zhowu8/ffK0F8eE
         8qhA==
X-Gm-Message-State: APjAAAUCWyf6+ZpaRfFdWN0F7qum0WmtK/nCRl4EoPvhy/vVh6RIPEMZ
	lLPxxYS7x3YJNkSyGf3xJwR/kRG4FcpV2BIo9v9lZkvHZllWe5fvBljHaN73QzdECEDMqWnjYvu
	iJSuxwJ3/O+y8yYxjYo7/66p0zK2PXY2Co/8vB0C5Q97NMQOlkrt4LamjnMRWT6jkKg==
X-Received: by 2002:a1c:ef1a:: with SMTP id n26mr1407618wmh.67.1552566696806;
        Thu, 14 Mar 2019 05:31:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxp5eqGvj/U/ZR3kzBB+kS65nT+KZTsrdAb1asN3PJJV89Lh0KQs10InFjSueyVJKEj+ZW/
X-Received: by 2002:a1c:ef1a:: with SMTP id n26mr1407541wmh.67.1552566695570;
        Thu, 14 Mar 2019 05:31:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552566695; cv=none;
        d=google.com; s=arc-20160816;
        b=u24CgzJXsQrm1i7cqQtvAj+WeJ0uTELRecrJwJ0pn2mTsRpDJcqAKeggCZ75sB3AHL
         pAU2dAMNzyk2sMfWqBQriNsWMZvpEFYfdMzS2OnPsFbLvbYqMHPCyOFNIa+B48UBZevc
         C6GnuTd3ZYqQCceVdD7IOsPhR3C5xBHO5hbaKO8WXRHzUUnwlm45XJlhY/Rm9YDWOS4b
         uwsZ9gY6GIZ0yfn3P2zojQMcYpRRM5WvkM6/VcgGqT2AaQbVp7wbkVWegE+hCwhJ0H/R
         KMXtmhsEX8U8hUgBsPorxxyq7rhpNtq7rtZ3QcH8RaKWHf8Jx0bfzEu5/OSOPZLyfD4u
         45yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:subject:date:to:from:mime-version
         :list-unsubscribe:message-id:errors-to:dkim-signature;
        bh=Ci/uaxv9SHgTeRXd9jOpvr/sP/RkeJ7ywDtAhRBjvQM=;
        b=lSCEugxx/MD7kEl7WrITvsAF6+p3Gl7ZGDKKlem+JKgSIRKOr5fPUp/TRQm+1sDLYT
         2sI0AIo7AcyJEKvl3PfQ6Hf2m/FBmZtD6T9ILQGenNg+5IrGhsN4Yx/m4RNAVMVzF/qv
         jkspFAhIO1MOcZRiAS5EN+gH+DAQhhy+P3oWPV1t0HAMH5OQt7s8FnaxCjjfpBagj/3i
         t9ofrA/fh5FVQqS7utaRJm3qqPfv9wx/ZNP2IEtxKt1aEa5f5oV+ycu2fzUKXsNdzy73
         0wQBdexjlRhXo5XpQrah3fDbyuf1fRqGolxLpNngbFOY9gKKgoj20lkjaxdy+Ci1fiYz
         hY6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@e.atlantisthepalm.com header.s=0 header.b=0N8FFe5K;
       spf=pass (google.com: domain of info@e.atlantisthepalm.com designates 62.144.109.110 as permitted sender) smtp.mailfrom=info@e.atlantisthepalm.com
Received: from mta109110.e.atlantisthepalm.com (mta109110.e.atlantisthepalm.com. [62.144.109.110])
        by mx.google.com with ESMTPS id x18si6001819wrv.199.2019.03.14.05.31.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 05:31:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of info@e.atlantisthepalm.com designates 62.144.109.110 as permitted sender) client-ip=62.144.109.110;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@e.atlantisthepalm.com header.s=0 header.b=0N8FFe5K;
       spf=pass (google.com: domain of info@e.atlantisthepalm.com designates 62.144.109.110 as permitted sender) smtp.mailfrom=info@e.atlantisthepalm.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; s=0; d=e.atlantisthepalm.com;
 h=Message-ID:List-Unsubscribe:MIME-Version:From:To:Date:Subject:Content-Type:
 Content-Transfer-Encoding; i=info@e.atlantisthepalm.com;
 bh=Ci/uaxv9SHgTeRXd9jOpvr/sP/RkeJ7ywDtAhRBjvQM=;
 b=0N8FFe5KeepR1qB3Wit3bg+x8dloIS20QiQ3PvasbL8xRlhTCB/ytbzCe/Pdtxr/suvi/gC6Hhiw
   U56SCL3pyro0PpuTH+4CZ+ZXASvLw9Itac2Oym4AR8ls4iG8lWO2Tbvmy22oEXkCJYeRwi5Fn/ET
   kHc+QHRVaKv2X+xK2zE=
Received: by mta109110.e.atlantisthepalm.com id hh94qa2bs1kt for <linux-mm@kvack.org>; Thu, 14 Mar 2019 12:31:23 +0000 (envelope-from <info@e.atlantisthepalm.com>)
Message-ID: <404.296280675.201903141231233050443.0008148782@e.atlantisthepalm.com>
List-Unsubscribe: <mailto:unsubscribe-cbb742231ff0c939543f3df666266f7d@e.atlantisthepalm.com?subject=Unsubscribe>
X-Mailer: XyzMailer
X-Xyz-cr: 404
X-Xyz-cn: 13677
X-Xyz-bcn: 13640
X-Xyz-md: 100
X-Xyz-mg: 296280675
X-Xyz-et: 100
X-Xyz-pk: 4004113
X-Xyz-ct: 43607
X-Xyz-bct: 43543
X-Xyz-Rcpt-Hash: bc96867026a5e550c7b391db36b07bc6a1f21c3b74d5c2c129d68884a168f9f5@kvack.org
MIME-Version: 1.0
From: "Atlantis, The Palm" <info@e.atlantisthepalm.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Date: 14 Mar 2019 12:31:23 +0000
Subject: Up to 25% off the all-new Imperial Club
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.398087, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "=
http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xm=
lns=3D"http://www.w3.org/1999/xhtml" xmlns:v=3D"urn:schemas-micro=
soft-com:vml" xmlns:o=3D"urn:schemas-microsoft-com:office:office"=
><head>=0A    <!--[if gte mso 9]><xml>=0A     <o:OfficeDocumentSe=
ttings>=0A      <o:AllowPNG/>=0A      <o:PixelsPerInch>96</o:Pixe=
lsPerInch>=0A     </o:OfficeDocumentSettings>=0A    </xml><![endi=
f]-->=0A    <meta http-equiv=3D"Content-Type" content=3D"text/htm=
l; charset=3Dutf-8">=0A    <meta name=3D"viewport" content=3D"wid=
th=3Ddevice-width">=0A    <!--[if !mso]><!--><meta http-equiv=3D"=
X-UA-Compatible" content=3D"IE=3Dedge"><!--<![endif]-->=0A    <ti=
tle></title>=0A    =0A    =0A    <style type=3D"text/css" id=3D"m=
edia-query">=0A      body {=0A  margin: 0;=0A  padding: 0; }=0A=0A=
table, tr, td {=0A  vertical-align: top;=0A  border-collapse: col=
lapse; }=0A=0A.ie-browser table, .mso-container table {=0A  table=
-layout: fixed; }=0A=0A* {=0A  line-height: inherit; }=0A=0Aa[x-a=
pple-data-detectors=3Dtrue] {=0A  color: inherit !important;=0A  =
text-decoration: none !important; }=0A=0A[owa] .img-container div=
, [owa] .img-container button {=0A  display: block !important; }=0A=
=0A[owa] .fullwidth button {=0A  width: 100% !important; }=0A=0A[=
owa] .block-grid .col {=0A  display: table-cell;=0A  float: none =
!important;=0A  vertical-align: top; }=0A=0A.ie-browser .num12, .=
ie-browser .block-grid, [owa] .num12, [owa] .block-grid {=0A  wid=
th: 600px !important; }=0A=0A.ExternalClass, .ExternalClass p, .E=
xternalClass span, .ExternalClass font, .ExternalClass td, .Exter=
nalClass div {=0A  line-height: 100%; }=0A=0A.ie-browser .mixed-t=
wo-up .num4, [owa] .mixed-two-up .num4 {=0A  width: 200px !import=
ant; }=0A=0A.ie-browser .mixed-two-up .num8, [owa] .mixed-two-up =
.num8 {=0A  width: 400px !important; }=0A=0A.ie-browser .block-gr=
id.two-up .col, [owa] .block-grid.two-up .col {=0A  width: 300px =
!important; }=0A=0A.ie-browser .block-grid.three-up .col, [owa] .=
block-grid.three-up .col {=0A  width: 200px !important; }=0A=0A.i=
e-browser .block-grid.four-up .col, [owa] .block-grid.four-up .co=
l {=0A  width: 150px !important; }=0A=0A.ie-browser .block-grid.f=
ive-up .col, [owa] .block-grid.five-up .col {=0A  width: 120px !i=
mportant; }=0A=0A.ie-browser .block-grid.six-up .col, [owa] .bloc=
k-grid.six-up .col {=0A  width: 100px !important; }=0A=0A.ie-brow=
ser .block-grid.seven-up .col, [owa] .block-grid.seven-up .col {=0A=
  width: 85px !important; }=0A=0A.ie-browser .block-grid.eight-up=
 .col, [owa] .block-grid.eight-up .col {=0A  width: 75px !importa=
nt; }=0A=0A.ie-browser .block-grid.nine-up .col, [owa] .block-gri=
d.nine-up .col {=0A  width: 66px !important; }=0A=0A.ie-browser .=
block-grid.ten-up .col, [owa] .block-grid.ten-up .col {=0A  width=
: 60px !important; }=0A=0A.ie-browser .block-grid.eleven-up .col,=
 [owa] .block-grid.eleven-up .col {=0A  width: 54px !important; }=
=0A=0A.ie-browser .block-grid.twelve-up .col, [owa] .block-grid.t=
welve-up .col {=0A  width: 50px !important; }=0A=0A@media only sc=
reen and (min-width: 620px) {=0A  .block-grid {=0A    width: 600p=
x !important; }=0A  .block-grid .col {=0A    vertical-align: top;=
 }=0A    .block-grid .col.num12 {=0A      width: 600px !important=
; }=0A  .block-grid.mixed-two-up .col.num4 {=0A    width: 200px !=
important; }=0A  .block-grid.mixed-two-up .col.num8 {=0A    width=
: 400px !important; }=0A  .block-grid.two-up .col {=0A    width: =
300px !important; }=0A  .block-grid.three-up .col {=0A    width: =
200px !important; }=0A  .block-grid.four-up .col {=0A    width: 1=
50px !important; }=0A  .block-grid.five-up .col {=0A    width: 12=
0px !important; }=0A  .block-grid.six-up .col {=0A    width: 100p=
x !important; }=0A  .block-grid.seven-up .col {=0A    width: 85px=
 !important; }=0A  .block-grid.eight-up .col {=0A    width: 75px =
!important; }=0A  .block-grid.nine-up .col {=0A    width: 66px !i=
mportant; }=0A  .block-grid.ten-up .col {=0A    width: 60px !impo=
rtant; }=0A  .block-grid.eleven-up .col {=0A    width: 54px !impo=
rtant; }=0A  .block-grid.twelve-up .col {=0A    width: 50px !impo=
rtant; } }=0A=0A@media (max-width: 620px) {=0A  .block-grid, .col=
 {=0A    min-width: 320px !important;=0A    max-width: 100% !impo=
rtant;=0A    display: block !important; }=0A  .block-grid {=0A   =
 width: calc(100% - 40px) !important; }=0A  .col {=0A    width: 1=
00% !important; }=0A    .col > div {=0A      margin: 0 auto; }=0A=
  img.fullwidth, img.fullwidthOnMobile {=0A    max-width: 100% !i=
mportant; }=0A  .no-stack .col {=0A    min-width: 0 !important;=0A=
    display: table-cell !important; }=0A  .no-stack.two-up .col {=
=0A    width: 50% !important; }=0A  .no-stack.mixed-two-up .col.n=
um4 {=0A    width: 33% !important; }=0A  .no-stack.mixed-two-up .=
col.num8 {=0A    width: 66% !important; }=0A  .no-stack.three-up =
.col.num4 {=0A    width: 33% !important; }=0A  .no-stack.four-up =
.col.num3 {=0A    width: 25% !important; }=0A  .mobile_hide {=0A =
   min-height: 0px;=0A    max-height: 0px;=0A    max-width: 0px;=0A=
    display: none;=0A    overflow: hidden;=0A    font-size: 0px; =
} }=0A=0A    </style>=0A</head>=0A<body class=3D"clean-body" styl=
e=3D"margin: 0;padding: 0;-webkit-text-size-adjust: 100%;backgrou=
nd-color: #FFFFFF"><img src=3D"http://l.e.atlantisthepalm.com/rts=
/open.aspx?tp=3Di-H43-6W-3Yb-K3A8Z-1c-GneT-1c-K2bgq-pmFM8" height=
=3D"1" width=3D"1" style=3D"display:none">=0A  <style type=3D"tex=
t/css" id=3D"media-query-bodytag">=0A    @media (max-width: 520px=
) {=0A      .block-grid {=0A        min-width: 320px!important;=0A=
        max-width: 100%!important;=0A        width: 100%!importan=
t;=0A        display: block!important;=0A      }=0A=0A      .col =
{=0A        min-width: 320px!important;=0A        max-width: 100%=
!important;=0A        width: 100%!important;=0A        display: b=
lock!important;=0A      }=0A=0A        .col > div {=0A          m=
argin: 0 auto;=0A        }=0A=0A      img.fullwidth {=0A        m=
ax-width: 100%!important;=0A      }=0Aimg.fullwidthOnMobile {=0A =
       max-width: 100%!important;=0A      }=0A      .no-stack .co=
l {=0Amin-width: 0!important;=0Adisplay: table-cell!important;=0A=
}=0A.no-stack.two-up .col {=0Awidth: 50%!important;=0A}=0A.no-sta=
ck.mixed-two-up .col.num4 {=0Awidth: 33%!important;=0A}=0A.no-sta=
ck.mixed-two-up .col.num8 {=0Awidth: 66%!important;=0A}=0A.no-sta=
ck.three-up .col.num4 {=0Awidth: 33%!important;=0A}=0A.no-stack.f=
our-up .col.num3 {=0Awidth: 25%!important;=0A}=0A      .mobile_hi=
de {=0A        min-height: 0px!important;=0A        max-height: 0=
px!important;=0A        max-width: 0px!important;=0A        displ=
ay: none!important;=0A        overflow: hidden!important;=0A     =
   font-size: 0px!important;=0A      }=0A    }=0A  </style>=0A  <=
!--[if IE]><div class=3D"ie-browser"><![endif]-->=0A  <!--[if mso=
]><div class=3D"mso-container"><![endif]-->=0A  <table class=3D"n=
l-container" style=3D"border-collapse: collapse;table-layout: fix=
ed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;=
vertical-align: top;min-width: 320px;Margin: 0 auto;background-co=
lor: #FFFFFF;width: 100%" cellpadding=3D"0" cellspacing=3D"0">=0A=
<tbody>=0A<tr style=3D"vertical-align: top">=0A<td style=3D"word-=
break: break-word;border-collapse: collapse !important;vertical-a=
lign: top">=0A    <!--[if (mso)|(IE)]><table width=3D"100%" cellp=
adding=3D"0" cellspacing=3D"0" border=3D"0"><tr><td align=3D"cent=
er" style=3D"background-color: #FFFFFF;"><![endif]-->=0A=0A    <d=
iv style=3D"background-color:#FFFFFF;">=0A      <div style=3D"Mar=
gin: 0 auto;min-width: 320px;max-width: 600px;overflow-wrap: brea=
k-word;word-wrap: break-word;word-break: break-word;background-co=
lor: transparent;" class=3D"block-grid ">=0A        <div style=3D=
"border-collapse: collapse;display: table;width: 100%;background-=
color:transparent;">=0A          <!--[if (mso)|(IE)]><table width=
=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><tr><t=
d style=3D"background-color:#FFFFFF;" align=3D"center"><table cel=
lpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"width: 600=
px;"><tr class=3D"layout-full-width" style=3D"background-color:tr=
ansparent;"><![endif]-->=0A=0A              <!--[if (mso)|(IE)]><=
td align=3D"center" width=3D"600" style=3D" width:600px; padding-=
right: 0px; padding-left: 0px; padding-top:5px; padding-bottom:5p=
x; border-top: 0px solid transparent; border-left: 0px solid tran=
sparent; border-bottom: 0px solid transparent; border-right: 0px =
solid transparent;" valign=3D"top"><![endif]-->=0A            <di=
v class=3D"col num12" style=3D"min-width: 320px;max-width: 600px;=
display: table-cell;vertical-align: top;">=0A              <div s=
tyle=3D"background-color: transparent; width: 100% !important;">=0A=
              <!--[if (!mso)&(!IE)]><!--><div style=3D"border-top=
: 0px solid transparent; border-left: 0px solid transparent; bord=
er-bottom: 0px solid transparent; border-right: 0px solid transpa=
rent; padding-top:5px; padding-bottom:5px; padding-right: 0px; pa=
dding-left: 0px;"><!--<![endif]-->=0A=0A                  =0A    =
                <div class=3D"">=0A<!--[if mso]><table width=3D"1=
00%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><tr><td sty=
le=3D"padding-right: 10px; padding-left: 10px; padding-top: 10px;=
 padding-bottom: 10px;"><![endif]-->=0A<div style=3D"color:#55555=
5;font-family:Verdana, Geneva, sans-serif;line-height:120%; paddi=
ng-right: 10px; padding-left: 10px; padding-top: 10px; padding-bo=
ttom: 10px;">=0A<div style=3D"font-size:12px;line-height:14px;col=
or:#555555;font-family:Verdana, Geneva, sans-serif;text-align:lef=
t;"><p style=3D"margin: 0;font-size: 14px;line-height: 17px;text-=
align: center"><span style=3D"font-size: 12px; line-height: 14px;=
">Up to 25% off Imperial Club&#160;- View the <span style=3D"colo=
r: rgb(51, 51, 51); font-size: 12px; line-height: 14px;"><strong>=
<a style=3D"text-decoration: none; color: #333333;" href=3D"http:=
//x.e.atlantisthepalm.com/ats/msg.aspx?sg1=3Dcbb742231ff0c939543f=
3df666266f7d" target=3D"_blank" rel=3D"noopener">web version</a><=
/strong></span></span></p></div>=0A</div>=0A<!--[if mso]></td></t=
r></table><![endif]-->=0A</div>=0A                  =0A          =
    <!--[if (!mso)&(!IE)]><!--></div><!--<![endif]-->=0A         =
     </div>=0A            </div>=0A          <!--[if (mso)|(IE)]>=
</td></tr></table></td></tr></table><![endif]-->=0A        </div>=
=0A      </div>=0A    </div>=0A    <div style=3D"background-color=
:transparent;">=0A      <div style=3D"Margin: 0 auto;min-width: 3=
20px;max-width: 600px;overflow-wrap: break-word;word-wrap: break-=
word;word-break: break-word;background-color: transparent;" class=
=3D"block-grid ">=0A        <div style=3D"border-collapse: collap=
se;display: table;width: 100%;background-color:transparent;">=0A =
         <!--[if (mso)|(IE)]><table width=3D"100%" cellpadding=3D=
"0" cellspacing=3D"0" border=3D"0"><tr><td style=3D"background-co=
lor:transparent;" align=3D"center"><table cellpadding=3D"0" cells=
pacing=3D"0" border=3D"0" style=3D"width: 600px;"><tr class=3D"la=
yout-full-width" style=3D"background-color:transparent;"><![endif=
]-->=0A=0A              <!--[if (mso)|(IE)]><td align=3D"center" =
width=3D"600" style=3D" width:600px; padding-right: 0px; padding-=
left: 0px; padding-top:15px; padding-bottom:15px; border-top: 0px=
 solid transparent; border-left: 0px solid transparent; border-bo=
ttom: 0px solid transparent; border-right: 0px solid transparent;=
" valign=3D"top"><![endif]-->=0A            <div class=3D"col num=
12" style=3D"min-width: 320px;max-width: 600px;display: table-cel=
l;vertical-align: top;">=0A              <div style=3D"background=
-color: transparent; width: 100% !important;">=0A              <!=
--[if (!mso)&(!IE)]><!--><div style=3D"border-top: 0px solid tran=
sparent; border-left: 0px solid transparent; border-bottom: 0px s=
olid transparent; border-right: 0px solid transparent; padding-to=
p:15px; padding-bottom:15px; padding-right: 0px; padding-left: 0p=
x;"><!--<![endif]-->=0A=0A                  =0A                  =
  <div align=3D"center" class=3D"img-container center fixedwidth =
" style=3D"padding-right: 0px;  padding-left: 0px;">=0A<!--[if ms=
o]><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" bord=
er=3D"0"><tr style=3D"line-height:0px;line-height:0px;"><td style=
=3D"padding-right: 0px; padding-left: 0px;" align=3D"center"><![e=
ndif]-->=0A  <a href=3D"http://l.e.atlantisthepalm.com/rts/go2.as=
px?h=3D121658&tp=3Di-H43-6W-3Yb-K3A8Z-1c-GneT-1c-K2bgq-pmFM8" tar=
get=3D"_blank">=0A    <img class=3D"center fixedwidth" align=3D"c=
enter" border=3D"0" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUplo=
ads/images/w_logo2x_.gif" alt=3D"Atlantis the palm" title=3D"Atla=
ntis the palm" style=3D"outline: none;text-decoration: none;-ms-i=
nterpolation-mode: bicubic;clear: both;display: block !important;=
border: none;height: auto;float: none;width: 100%;max-width: 150p=
x" width=3D"150">=0A  </a>=0A<!--[if mso]></td></tr></table><![en=
dif]-->=0A</div>=0A=0A                  =0A              <!--[if =
(!mso)&(!IE)]><!--></div><!--<![endif]-->=0A              </div>=0A=
            </div>=0A          <!--[if (mso)|(IE)]></td></tr></ta=
ble></td></tr></table><![endif]-->=0A        </div>=0A      </div=
>=0A    </div>=0A    <div style=3D"background-color:transparent;"=
>=0A      <div style=3D"Margin: 0 auto;min-width: 320px;max-width=
: 600px;overflow-wrap: break-word;word-wrap: break-word;word-brea=
k: break-word;background-color: transparent;" class=3D"block-grid=
 ">=0A        <div style=3D"border-collapse: collapse;display: ta=
ble;width: 100%;background-color:transparent;">=0A          <!--[=
if (mso)|(IE)]><table width=3D"100%" cellpadding=3D"0" cellspacin=
g=3D"0" border=3D"0"><tr><td style=3D"background-color:transparen=
t;" align=3D"center"><table cellpadding=3D"0" cellspacing=3D"0" b=
order=3D"0" style=3D"width: 600px;"><tr class=3D"layout-full-widt=
h" style=3D"background-color:transparent;"><![endif]-->=0A=0A    =
          <!--[if (mso)|(IE)]><td align=3D"center" width=3D"600" =
style=3D" width:600px; padding-right: 0px; padding-left: 0px; pad=
ding-top:0px; padding-bottom:0px; border-top: 0px solid transpare=
nt; border-left: 0px solid transparent; border-bottom: 0px solid =
transparent; border-right: 0px solid transparent;" valign=3D"top"=
><![endif]-->=0A            <div class=3D"col num12" style=3D"min=
-width: 320px;max-width: 600px;display: table-cell;vertical-align=
: top;">=0A              <div style=3D"background-color: transpar=
ent; width: 100% !important;">=0A              <!--[if (!mso)&(!I=
E)]><!--><div style=3D"border-top: 0px solid transparent; border-=
left: 0px solid transparent; border-bottom: 0px solid transparent=
; border-right: 0px solid transparent; padding-top:0px; padding-b=
ottom:0px; padding-right: 0px; padding-left: 0px;"><!--<![endif]-=
->=0A=0A                  =0A                    <div align=3D"ce=
nter" class=3D"img-container center  autowidth  fullwidth " style=
=3D"padding-right: 0px;  padding-left: 0px;">=0A<!--[if mso]><tab=
le width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0=
"><tr style=3D"line-height:0px;line-height:0px;"><td style=3D"pad=
ding-right: 0px; padding-left: 0px;" align=3D"center"><![endif]--=
>=0A  <a href=3D"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D=
121658&tp=3Di-H43-6W-3Yb-K3A8Z-1c-GneT-1c-K2bgq-pmFM8" target=3D"=
_blank">=0A    <img class=3D"center  autowidth  fullwidth" align=3D=
"center" border=3D"0" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUp=
loads/images/img/IC_Remailer_NonMember_Hero.jpg" alt=3D"Imperial =
Club Emailer 35% Off" title=3D"Imperial Club Emailer 35% Off" sty=
le=3D"outline: none;text-decoration: none;-ms-interpolation-mode:=
 bicubic;clear: both;display: block !important;border: none;heigh=
t: auto;float: none;width: 100%;max-width: 600px" width=3D"600">=0A=
  </a>=0A<!--[if mso]></td></tr></table><![endif]-->=0A</div>=0A=0A=
                  =0A              <!--[if (!mso)&(!IE)]><!--></d=
iv><!--<![endif]-->=0A              </div>=0A            </div>=0A=
          <!--[if (mso)|(IE)]></td></tr></table></td></tr></table=
><![endif]-->=0A        </div>=0A      </div>=0A    </div>=0A    =
<div style=3D"background-color:transparent;">=0A      <div style=3D=
"Margin: 0 auto;min-width: 320px;max-width: 600px;overflow-wrap: =
break-word;word-wrap: break-word;word-break: break-word;backgroun=
d-color: transparent;" class=3D"block-grid ">=0A        <div styl=
e=3D"border-collapse: collapse;display: table;width: 100%;backgro=
und-color:transparent;">=0A          <!--[if (mso)|(IE)]><table w=
idth=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><t=
r><td style=3D"background-color:transparent;" align=3D"center"><t=
able cellpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"wi=
dth: 600px;"><tr class=3D"layout-full-width" style=3D"background-=
color:transparent;"><![endif]-->=0A=0A              <!--[if (mso)=
|(IE)]><td align=3D"center" width=3D"600" style=3D" width:600px; =
padding-right: 0px; padding-left: 0px; padding-top:0px; padding-b=
ottom:0px; border-top: 0px solid transparent; border-left: 0px so=
lid transparent; border-bottom: 0px solid transparent; border-rig=
ht: 0px solid transparent;" valign=3D"top"><![endif]-->=0A       =
     <div class=3D"col num12" style=3D"min-width: 320px;max-width=
: 600px;display: table-cell;vertical-align: top;">=0A            =
  <div style=3D"background-color: transparent; width: 100% !impor=
tant;">=0A              <!--[if (!mso)&(!IE)]><!--><div style=3D"=
border-top: 0px solid transparent; border-left: 0px solid transpa=
rent; border-bottom: 0px solid transparent; border-right: 0px sol=
id transparent; padding-top:0px; padding-bottom:0px; padding-righ=
t: 0px; padding-left: 0px;"><!--<![endif]-->=0A=0A               =
   =0A                    <div align=3D"center" class=3D"img-cont=
ainer center  autowidth  fullwidth " style=3D"padding-right: 0px;=
  padding-left: 0px;">=0A<!--[if mso]><table width=3D"100%" cellp=
adding=3D"0" cellspacing=3D"0" border=3D"0"><tr style=3D"line-hei=
ght:0px;line-height:0px;"><td style=3D"padding-right: 0px; paddin=
g-left: 0px;" align=3D"center"><![endif]-->=0A  <a href=3D"http:/=
/l.e.atlantisthepalm.com/rts/go2.aspx?h=3D121658&tp=3Di-H43-6W-3Y=
b-K3A8Z-1c-GneT-1c-K2bgq-pmFM8" target=3D"_blank">=0A    <img cla=
ss=3D"center  autowidth  fullwidth" align=3D"center" border=3D"0"=
 src=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/images/img/IC_R=
emailer_NonMember_1.jpg" alt=3D"Little things that make a big dif=
ference" title=3D"Little things that make a big difference" style=
=3D"outline: none;text-decoration: none;-ms-interpolation-mode: b=
icubic;clear: both;display: block !important;border: none;height:=
 auto;float: none;width: 100%;max-width: 600px" width=3D"600">=0A=
  </a>=0A<!--[if mso]></td></tr></table><![endif]-->=0A</div>=0A=0A=
                  =0A              <!--[if (!mso)&(!IE)]><!--></d=
iv><!--<![endif]-->=0A              </div>=0A            </div>=0A=
          <!--[if (mso)|(IE)]></td></tr></table></td></tr></table=
><![endif]-->=0A        </div>=0A      </div>=0A    </div>=0A    =
<div style=3D"background-color:transparent;">=0A      <div style=3D=
"Margin: 0 auto;min-width: 320px;max-width: 600px;overflow-wrap: =
break-word;word-wrap: break-word;word-break: break-word;backgroun=
d-color: transparent;" class=3D"block-grid ">=0A        <div styl=
e=3D"border-collapse: collapse;display: table;width: 100%;backgro=
und-color:transparent;">=0A          <!--[if (mso)|(IE)]><table w=
idth=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><t=
r><td style=3D"background-color:transparent;" align=3D"center"><t=
able cellpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"wi=
dth: 600px;"><tr class=3D"layout-full-width" style=3D"background-=
color:transparent;"><![endif]-->=0A=0A              <!--[if (mso)=
|(IE)]><td align=3D"center" width=3D"600" style=3D" width:600px; =
padding-right: 0px; padding-left: 0px; padding-top:0px; padding-b=
ottom:0px; border-top: 0px solid transparent; border-left: 0px so=
lid transparent; border-bottom: 0px solid transparent; border-rig=
ht: 0px solid transparent;" valign=3D"top"><![endif]-->=0A       =
     <div class=3D"col num12" style=3D"min-width: 320px;max-width=
: 600px;display: table-cell;vertical-align: top;">=0A            =
  <div style=3D"background-color: transparent; width: 100% !impor=
tant;">=0A              <!--[if (!mso)&(!IE)]><!--><div style=3D"=
border-top: 0px solid transparent; border-left: 0px solid transpa=
rent; border-bottom: 0px solid transparent; border-right: 0px sol=
id transparent; padding-top:0px; padding-bottom:0px; padding-righ=
t: 0px; padding-left: 0px;"><!--<![endif]-->=0A=0A               =
   =0A                    <div align=3D"center" class=3D"img-cont=
ainer center  autowidth  fullwidth " style=3D"padding-right: 0px;=
  padding-left: 0px;">=0A<!--[if mso]><table width=3D"100%" cellp=
adding=3D"0" cellspacing=3D"0" border=3D"0"><tr style=3D"line-hei=
ght:0px;line-height:0px;"><td style=3D"padding-right: 0px; paddin=
g-left: 0px;" align=3D"center"><![endif]-->=0A  <a href=3D"http:/=
/l.e.atlantisthepalm.com/rts/go2.aspx?h=3D121658&tp=3Di-H43-6W-3Y=
b-K3A8Z-1c-GneT-1c-K2bgq-pmFM8" target=3D"_blank">=0A    <img cla=
ss=3D"center  autowidth  fullwidth" align=3D"center" border=3D"0"=
 src=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/images/img/IC_R=
emailer_NonMember_2_V2.jpg" alt=3D"Make your holiday with sun and=
 kids" title=3D"Make your holiday with sun and kids" style=3D"out=
line: none;text-decoration: none;-ms-interpolation-mode: bicubic;=
clear: both;display: block !important;border: none;height: auto;f=
loat: none;width: 100%;max-width: 600px" width=3D"600">=0A  </a>=0A=
<!--[if mso]></td></tr></table><![endif]-->=0A</div>=0A=0A       =
           =0A              <!--[if (!mso)&(!IE)]><!--></div><!--=
<![endif]-->=0A              </div>=0A            </div>=0A      =
    <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![en=
dif]-->=0A        </div>=0A      </div>=0A    </div>=0A    <div s=
tyle=3D"background-color:transparent;">=0A      <div style=3D"Mar=
gin: 0 auto;min-width: 320px;max-width: 600px;overflow-wrap: brea=
k-word;word-wrap: break-word;word-break: break-word;background-co=
lor: transparent;" class=3D"block-grid ">=0A        <div style=3D=
"border-collapse: collapse;display: table;width: 100%;background-=
color:transparent;">=0A          <!--[if (mso)|(IE)]><table width=
=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><tr><t=
d style=3D"background-color:transparent;" align=3D"center"><table=
 cellpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"width:=
 600px;"><tr class=3D"layout-full-width" style=3D"background-colo=
r:transparent;"><![endif]-->=0A=0A              <!--[if (mso)|(IE=
)]><td align=3D"center" width=3D"600" style=3D" width:600px; padd=
ing-right: 0px; padding-left: 0px; padding-top:0px; padding-botto=
m:0px; border-top: 0px solid transparent; border-left: 0px solid =
transparent; border-bottom: 0px solid transparent; border-right: =
0px solid transparent;" valign=3D"top"><![endif]-->=0A           =
 <div class=3D"col num12" style=3D"min-width: 320px;max-width: 60=
0px;display: table-cell;vertical-align: top;">=0A              <d=
iv style=3D"background-color: transparent; width: 100% !important=
;">=0A              <!--[if (!mso)&(!IE)]><!--><div style=3D"bord=
er-top: 0px solid transparent; border-left: 0px solid transparent=
; border-bottom: 0px solid transparent; border-right: 0px solid t=
ransparent; padding-top:0px; padding-bottom:0px; padding-right: 0=
px; padding-left: 0px;"><!--<![endif]-->=0A=0A                  =0A=
                    <div align=3D"center" class=3D"img-container =
center  autowidth  fullwidth " style=3D"padding-right: 0px;  padd=
ing-left: 0px;">=0A<!--[if mso]><table width=3D"100%" cellpadding=
=3D"0" cellspacing=3D"0" border=3D"0"><tr style=3D"line-height:0p=
x;line-height:0px;"><td style=3D"padding-right: 0px; padding-left=
: 0px;" align=3D"center"><![endif]-->=0A  <a href=3D"http://l.e.a=
tlantisthepalm.com/rts/go2.aspx?h=3D121658&tp=3Di-H43-6W-3Yb-K3A8=
Z-1c-GneT-1c-K2bgq-pmFM8" target=3D"_blank">=0A    <img class=3D"=
center  autowidth  fullwidth" align=3D"center" border=3D"0" src=3D=
"http://wpm.ccmp.eu/wpm/404/ContentUploads/images/img/IC_Remailer=
_NonMember_3.jpg" alt=3D"Imperial club Queen room" title=3D"Imper=
ial club Queen room" style=3D"outline: none;text-decoration: none=
;-ms-interpolation-mode: bicubic;clear: both;display: block !impo=
rtant;border: none;height: auto;float: none;width: 100%;max-width=
: 600px" width=3D"600">=0A  </a>=0A<!--[if mso]></td></tr></table=
><![endif]-->=0A</div>=0A=0A                  =0A              <!=
--[if (!mso)&(!IE)]><!--></div><!--<![endif]-->=0A              <=
/div>=0A            </div>=0A          <!--[if (mso)|(IE)]></td><=
/tr></table></td></tr></table><![endif]-->=0A        </div>=0A   =
   </div>=0A    </div>=0A    <div style=3D"background-color:trans=
parent;">=0A      <div style=3D"Margin: 0 auto;min-width: 320px;m=
ax-width: 600px;overflow-wrap: break-word;word-wrap: break-word;w=
ord-break: break-word;background-color: transparent;" class=3D"bl=
ock-grid ">=0A        <div style=3D"border-collapse: collapse;dis=
play: table;width: 100%;background-color:transparent;">=0A       =
   <!--[if (mso)|(IE)]><table width=3D"100%" cellpadding=3D"0" ce=
llspacing=3D"0" border=3D"0"><tr><td style=3D"background-color:tr=
ansparent;" align=3D"center"><table cellpadding=3D"0" cellspacing=
=3D"0" border=3D"0" style=3D"width: 600px;"><tr class=3D"layout-f=
ull-width" style=3D"background-color:transparent;"><![endif]-->=0A=
=0A              <!--[if (mso)|(IE)]><td align=3D"center" width=3D=
"600" style=3D" width:600px; padding-right: 0px; padding-left: 0p=
x; padding-top:0px; padding-bottom:0px; border-top: 0px solid tra=
nsparent; border-left: 0px solid transparent; border-bottom: 0px =
solid transparent; border-right: 0px solid transparent;" valign=3D=
"top"><![endif]-->=0A            <div class=3D"col num12" style=3D=
"min-width: 320px;max-width: 600px;display: table-cell;vertical-a=
lign: top;">=0A              <div style=3D"background-color: tran=
sparent; width: 100% !important;">=0A              <!--[if (!mso)=
&(!IE)]><!--><div style=3D"border-top: 0px solid transparent; bor=
der-left: 0px solid transparent; border-bottom: 0px solid transpa=
rent; border-right: 0px solid transparent; padding-top:0px; paddi=
ng-bottom:0px; padding-right: 0px; padding-left: 0px;"><!--<![end=
if]-->=0A=0A                  =0A                    <div align=3D=
"center" class=3D"img-container center  autowidth  fullwidth " st=
yle=3D"padding-right: 0px;  padding-left: 0px;">=0A<!--[if mso]><=
table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D=
"0"><tr style=3D"line-height:0px;line-height:0px;"><td style=3D"p=
adding-right: 0px; padding-left: 0px;" align=3D"center"><![endif]=
-->=0A  <a href=3D"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D=
121658&tp=3Di-H43-6W-3Yb-K3A8Z-1c-GneT-1c-K2bgq-pmFM8" target=3D"=
_blank">=0A    <img class=3D"center  autowidth  fullwidth" align=3D=
"center" border=3D"0" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUp=
loads/images/img/IC_Remailer_NonMember_4.jpg" alt=3D"Enjoy unlimi=
ted access to Aquaventure Waterpark" title=3D"Enjoy unlimited acc=
ess to Aquaventure Waterpark" style=3D"outline: none;text-decorat=
ion: none;-ms-interpolation-mode: bicubic;clear: both;display: bl=
ock !important;border: none;height: auto;float: none;width: 100%;=
max-width: 600px" width=3D"600">=0A  </a>=0A<!--[if mso]></td></t=
r></table><![endif]-->=0A</div>=0A=0A                  =0A       =
       <!--[if (!mso)&(!IE)]><!--></div><!--<![endif]-->=0A      =
        </div>=0A            </div>=0A          <!--[if (mso)|(IE=
)]></td></tr></table></td></tr></table><![endif]-->=0A        </d=
iv>=0A      </div>=0A    </div>=0A    <div style=3D"background-co=
lor:transparent;">=0A      <div style=3D"Margin: 0 auto;min-width=
: 320px;max-width: 600px;overflow-wrap: break-word;word-wrap: bre=
ak-word;word-break: break-word;background-color: transparent;" cl=
ass=3D"block-grid ">=0A        <div style=3D"border-collapse: col=
lapse;display: table;width: 100%;background-color:transparent;">=0A=
          <!--[if (mso)|(IE)]><table width=3D"100%" cellpadding=3D=
"0" cellspacing=3D"0" border=3D"0"><tr><td style=3D"background-co=
lor:transparent;" align=3D"center"><table cellpadding=3D"0" cells=
pacing=3D"0" border=3D"0" style=3D"width: 600px;"><tr class=3D"la=
yout-full-width" style=3D"background-color:transparent;"><![endif=
]-->=0A=0A              <!--[if (mso)|(IE)]><td align=3D"center" =
width=3D"600" style=3D" width:600px; padding-right: 0px; padding-=
left: 0px; padding-top:0px; padding-bottom:0px; border-top: 0px s=
olid transparent; border-left: 0px solid transparent; border-bott=
om: 0px solid transparent; border-right: 0px solid transparent;" =
valign=3D"top"><![endif]-->=0A            <div class=3D"col num12=
" style=3D"min-width: 320px;max-width: 600px;display: table-cell;=
vertical-align: top;">=0A              <div style=3D"background-c=
olor: transparent; width: 100% !important;">=0A              <!--=
[if (!mso)&(!IE)]><!--><div style=3D"border-top: 0px solid transp=
arent; border-left: 0px solid transparent; border-bottom: 0px sol=
id transparent; border-right: 0px solid transparent; padding-top:=
0px; padding-bottom:0px; padding-right: 0px; padding-left: 0px;">=
<!--<![endif]-->=0A=0A                  =0A                    <d=
iv align=3D"center" class=3D"img-container center  autowidth  ful=
lwidth " style=3D"padding-right: 0px;  padding-left: 0px;">=0A<!-=
-[if mso]><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"=
0" border=3D"0"><tr style=3D"line-height:0px;line-height:0px;"><t=
d style=3D"padding-right: 0px; padding-left: 0px;" align=3D"cente=
r"><![endif]-->=0A                        <video style=3D"display=
:block;" poster=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/imag=
es/ImperialClub/IC_NonMember_6.jpg" width=3D"100%" height=3D"auto=
" controls=3D"controls">=0A                            <source sr=
c=3D"http://movableink-animated-pic-video-production.s3.amazonaws=
.com/7658/c35bbfaa39d0471e/1/640k.mp4" type=3D"video/mp4" />=0A  =
                          <a href=3D"http://l.e.atlantisthepalm.c=
om/rts/go2.aspx?h=3D121659&tp=3Di-H43-6W-3Yb-K3A8Z-1c-GneT-1c-K2b=
gq-pmFM8"><img src=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/i=
mages/ImperialClub/IC_NonMember_6.jpg" width=3D"100%" alt=3D"imag=
e instead of video" /></a>=0A                        </video>=0A<=
!--[if mso]></td></tr></table><![endif]-->=0A</div>=0A=0A        =
          =0A              <!--[if (!mso)&(!IE)]><!--></div><!--<=
![endif]-->=0A              </div>=0A            </div>=0A       =
   <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![end=
if]-->=0A        </div>=0A      </div>=0A    </div>=0A    <div st=
yle=3D"background-color:transparent;">=0A      <div style=3D"Marg=
in: 0 auto;min-width: 320px;max-width: 600px;overflow-wrap: break=
-word;word-wrap: break-word;word-break: break-word;background-col=
or: transparent;" class=3D"block-grid ">=0A        <div style=3D"=
border-collapse: collapse;display: table;width: 100%;background-c=
olor:transparent;">=0A          <!--[if (mso)|(IE)]><table width=3D=
"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><tr><td s=
tyle=3D"background-color:transparent;" align=3D"center"><table ce=
llpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"width: 60=
0px;"><tr class=3D"layout-full-width" style=3D"background-color:t=
ransparent;"><![endif]-->=0A=0A              <!--[if (mso)|(IE)]>=
<td align=3D"center" width=3D"600" style=3D" width:600px; padding=
-right: 0px; padding-left: 0px; padding-top:0px; padding-bottom:0=
px; border-top: 0px solid transparent; border-left: 0px solid tra=
nsparent; border-bottom: 0px solid transparent; border-right: 0px=
 solid transparent;" valign=3D"top"><![endif]-->=0A            <d=
iv class=3D"col num12" style=3D"min-width: 320px;max-width: 600px=
;display: table-cell;vertical-align: top;">=0A              <div =
style=3D"background-color: transparent; width: 100% !important;">=
=0A              <!--[if (!mso)&(!IE)]><!--><div style=3D"border-=
top: 0px solid transparent; border-left: 0px solid transparent; b=
order-bottom: 0px solid transparent; border-right: 0px solid tran=
sparent; padding-top:0px; padding-bottom:0px; padding-right: 0px;=
 padding-left: 0px;"><!--<![endif]-->=0A=0A                  =0A =
                   <div align=3D"center" class=3D"img-container c=
enter  autowidth  fullwidth " style=3D"padding-right: 0px;  paddi=
ng-left: 0px;">=0A<!--[if mso]><table width=3D"100%" cellpadding=3D=
"0" cellspacing=3D"0" border=3D"0"><tr style=3D"line-height:0px;l=
ine-height:0px;"><td style=3D"padding-right: 0px; padding-left: 0=
px;" align=3D"center"><![endif]-->=0A  <a href=3D"http://l.e.atla=
ntisthepalm.com/rts/go2.aspx?h=3D121658&tp=3Di-H43-6W-3Yb-K3A8Z-1=
c-GneT-1c-K2bgq-pmFM8" target=3D"_blank">=0A    <img class=3D"cen=
ter  autowidth  fullwidth" align=3D"center" border=3D"0" src=3D"h=
ttp://wpm.ccmp.eu/wpm/404/ContentUploads/images/img/IC_Remailer_N=
onMember_6.jpg" alt=3D"Experience a world" title=3D"Experience a =
world" style=3D"outline: none;text-decoration: none;-ms-interpola=
tion-mode: bicubic;clear: both;display: block !important;border: =
none;height: auto;float: none;width: 100%;max-width: 600px" width=
=3D"600">=0A  </a>=0A<!--[if mso]></td></tr></table><![endif]-->=0A=
</div>=0A=0A                  =0A              <!--[if (!mso)&(!I=
E)]><!--></div><!--<![endif]-->=0A              </div>=0A        =
    </div>=0A          <!--[if (mso)|(IE)]></td></tr></table></td=
></tr></table><![endif]-->=0A        </div>=0A      </div>=0A    =
</div>=0A    <div style=3D"background-color:transparent;">=0A    =
  <div style=3D"Margin: 0 auto;min-width: 320px;max-width: 600px;=
overflow-wrap: break-word;word-wrap: break-word;word-break: break=
-word;background-color: transparent;" class=3D"block-grid ">=0A  =
      <div style=3D"border-collapse: collapse;display: table;widt=
h: 100%;background-color:transparent;">=0A          <!--[if (mso)=
|(IE)]><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" =
border=3D"0"><tr><td style=3D"background-color:transparent;" alig=
n=3D"center"><table cellpadding=3D"0" cellspacing=3D"0" border=3D=
"0" style=3D"width: 600px;"><tr class=3D"layout-full-width" style=
=3D"background-color:transparent;"><![endif]-->=0A=0A            =
  <!--[if (mso)|(IE)]><td align=3D"center" width=3D"600" style=3D=
" width:600px; padding-right: 0px; padding-left: 0px; padding-top=
:15px; padding-bottom:5px; border-top: 0px solid transparent; bor=
der-left: 0px solid transparent; border-bottom: 0px solid transpa=
rent; border-right: 0px solid transparent;" valign=3D"top"><![end=
if]-->=0A            <div class=3D"col num12" style=3D"min-width:=
 320px;max-width: 600px;display: table-cell;vertical-align: top;"=
>=0A              <div style=3D"background-color: transparent; wi=
dth: 100% !important;">=0A              <!--[if (!mso)&(!IE)]><!-=
-><div style=3D"border-top: 0px solid transparent; border-left: 0=
px solid transparent; border-bottom: 0px solid transparent; borde=
r-right: 0px solid transparent; padding-top:15px; padding-bottom:=
5px; padding-right: 0px; padding-left: 0px;"><!--<![endif]-->=0A=0A=
                  =0A                    <div class=3D"">=0A<!--[=
if mso]><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0"=
 border=3D"0"><tr><td style=3D"padding-right: 10px; padding-left:=
 10px; padding-top: 10px; padding-bottom: 10px;"><![endif]-->=0A<=
div style=3D"color:#555555;font-family:Verdana, Geneva, sans-seri=
f;line-height:120%; padding-right: 10px; padding-left: 10px; padd=
ing-top: 10px; padding-bottom: 10px;">=0A<div style=3D"font-size:=
12px;line-height:14px;color:#555555;font-family:Verdana, Geneva, =
sans-serif;text-align:left;"><p style=3D"margin: 0;font-size: 12p=
x;line-height: 14px;text-align: center"><span style=3D"font-size:=
 24px; line-height: 28px; color: rgb(0, 101, 162);">Tell my frien=
ds</span></p></div>=0A</div>=0A<!--[if mso]></td></tr></table><![=
endif]-->=0A</div>=0A                  =0A                  =0A  =
                  <div class=3D"" style=3D"font-size: 16px;font-f=
amily:Verdana, Geneva, sans-serif; text-align: center;"><div clas=
s=3D"our-class"> =0A<table align=3D"center" border=3D"0" cellpadd=
ing=3D"0" cellspacing=3D"0">=0A<tbody>=0A<tr>=0A                 =
     <td><a href=3D"#" target=3D"_blank"><img alt=3D"instagram" b=
order=3D"0" height=3D"30" src=3D"http://wpm.ccmp.eu/wpm/404/Conte=
ntUploads/images/img/Instagram_Image.png" width=3D"30"></a></td>=0A=
<td><img border=3D"0" height=3D"20" src=3D"http://wpm.ccmp.eu/wpm=
/404/ContentUploads/images/t.gif" style=3D"display:block;" width=3D=
"10"></td>=0A<td><a href=3D"http://l.e.atlantisthepalm.com/rts/so=
cial.aspx?tp=3Di-H43-6W-3Yb-K3A8Z-1c-GneT-1c-K2bgq-pmFM8&amp;sn=3D=
02&amp;domain=3Dx.e.atlantisthepalm.com" target=3D"_blank"><img a=
lt=3D"facebook" border=3D"0" height=3D"30" src=3D"http://wpm.ccmp=
.eu/wpm/404/ContentUploads/images/w_facebook2x_.gif" width=3D"30"=
></a></td>=0A<td><img border=3D"0" height=3D"20" src=3D"http://wp=
m.ccmp.eu/wpm/404/ContentUploads/images/t.gif" style=3D"display:b=
lock;" width=3D"10"></td>=0A<td><a href=3D"http://l.e.atlantisthe=
palm.com/rts/social.aspx?tp=3Di-H43-6W-3Yb-K3A8Z-1c-GneT-1c-K2bgq=
-pmFM8&amp;sn=3D18&amp;domain=3Dx.e.atlantisthepalm.com" target=3D=
"_blank"><img alt=3D"linkedin" border=3D"0" height=3D"30" src=3D"=
http://wpm.ccmp.eu/wpm/404/ContentUploads/images/w_linkedin2x_.gi=
f" width=3D"30"></a></td>=0A<td><img border=3D"0" height=3D"20" s=
rc=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/images/t.gif" sty=
le=3D"display:block;" width=3D"10"></td>=0A<td><a href=3D"http://=
l.e.atlantisthepalm.com/rts/social.aspx?tp=3Di-H43-6W-3Yb-K3A8Z-1=
c-GneT-1c-K2bgq-pmFM8&amp;sn=3D03&amp;domain=3Dx.e.atlantisthepal=
m.com" target=3D"_blank"><img alt=3D"twitter" border=3D"0" height=
=3D"30" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/images/w=
_twitter2x_.gif" width=3D"30"></a></td>=0A<td><img border=3D"0" h=
eight=3D"20" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/ima=
ges/t.gif" style=3D"display:block;" width=3D"10"></td>=0A<td><a h=
ref=3D"mailto:?subject=3DAtlantis%20Spring%20Sale%20is%20now%20on=
!&amp;body=3D=0A                                                 =
       Up%20to%2030%25%20off%20rooms!%20Book%20now%20at%20atlanti=
sthepalm.com/sale%0A%0Ahttp%3A%2F%2Fx.e.atlantisthepalm.com%2Fats=
%2Fsocial.aspx%3Ftp%3Di-H43-6W-3Yb-K3A8Z-1c-GneT-1c-K2bgq-pmFM8" =
target=3D"_blank"><img alt=3D"sms" border=3D"0" src=3D"http://wpm=
.ccmp.eu/wpm/404/ContentUploads/images/w_mailto2x_.gif" width=3D"=
30"></a></td>=0A</tr>=0A</tbody>=0A</table>=0A</div></div>=0A=0A =
                 =0A              <!--[if (!mso)&(!IE)]><!--></di=
v><!--<![endif]-->=0A              </div>=0A            </div>=0A=
          <!--[if (mso)|(IE)]></td></tr></table></td></tr></table=
><![endif]-->=0A        </div>=0A      </div>=0A    </div>=0A    =
<div style=3D"background-color:transparent;">=0A      <div style=3D=
"Margin: 0 auto;min-width: 320px;max-width: 600px;overflow-wrap: =
break-word;word-wrap: break-word;word-break: break-word;backgroun=
d-color: transparent;" class=3D"block-grid three-up ">=0A        =
<div style=3D"border-collapse: collapse;display: table;width: 100=
%;background-color:transparent;">=0A          <!--[if (mso)|(IE)]=
><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=
=3D"0"><tr><td style=3D"background-color:transparent;" align=3D"c=
enter"><table cellpadding=3D"0" cellspacing=3D"0" border=3D"0" st=
yle=3D"width: 600px;"><tr class=3D"layout-full-width" style=3D"ba=
ckground-color:transparent;"><![endif]-->=0A=0A              <!--=
[if (mso)|(IE)]><td align=3D"center" width=3D"200" style=3D" widt=
h:200px; padding-right: 0px; padding-left: 0px; padding-top:10px;=
 padding-bottom:5px; border-top: 0px solid transparent; border-le=
ft: 0px solid transparent; border-bottom: 0px solid transparent; =
border-right: 0px solid transparent;" valign=3D"top"><![endif]-->=
=0A            <div class=3D"col num4" style=3D"max-width: 320px;=
min-width: 200px;display: table-cell;vertical-align: top;">=0A   =
           <div style=3D"background-color: transparent; width: 10=
0% !important;">=0A              <!--[if (!mso)&(!IE)]><!--><div =
style=3D"border-top: 0px solid transparent; border-left: 0px soli=
d transparent; border-bottom: 0px solid transparent; border-right=
: 0px solid transparent; padding-top:10px; padding-bottom:5px; pa=
dding-right: 0px; padding-left: 0px;"><!--<![endif]-->=0A=0A     =
             =0A                    <div align=3D"center" class=3D=
"img-container center fixedwidth " style=3D"padding-right: 0px;  =
padding-left: 0px;">=0A<!--[if mso]><table width=3D"100%" cellpad=
ding=3D"0" cellspacing=3D"0" border=3D"0"><tr style=3D"line-heigh=
t:0px;line-height:0px;"><td style=3D"padding-right: 0px; padding-=
left: 0px;" align=3D"center"><![endif]-->=0A  <a href=3D"http://l=
.e.atlantisthepalm.com/rts/go2.aspx?h=3D121660&tp=3Di-H43-6W-3Yb-=
K3A8Z-1c-GneT-1c-K2bgq-pmFM8" target=3D"_blank">=0A    <img class=
=3D"center fixedwidth" align=3D"center" border=3D"0" src=3D"http:=
//wpm.ccmp.eu/wpm/404/ContentUploads/images/w_livecam2x_new.gif" =
alt=3D"Atlantis Live Cam" title=3D"Atlantis Live Cam" style=3D"ou=
tline: none;text-decoration: none;-ms-interpolation-mode: bicubic=
;clear: both;display: block !important;border: none;height: auto;=
float: none;width: 100%;max-width: 170px" width=3D"170">=0A  </a>=
=0A<!--[if mso]></td></tr></table><![endif]-->=0A</div>=0A=0A    =
              =0A              <!--[if (!mso)&(!IE)]><!--></div><=
!--<![endif]-->=0A              </div>=0A            </div>=0A   =
           <!--[if (mso)|(IE)]></td><td align=3D"center" width=3D=
"200" style=3D" width:200px; padding-right: 0px; padding-left: 0p=
x; padding-top:10px; padding-bottom:5px; border-top: 0px solid tr=
ansparent; border-left: 0px solid transparent; border-bottom: 0px=
 solid transparent; border-right: 0px solid transparent;" valign=3D=
"top"><![endif]-->=0A            <div class=3D"col num4" style=3D=
"max-width: 320px;min-width: 200px;display: table-cell;vertical-a=
lign: top;">=0A              <div style=3D"background-color: tran=
sparent; width: 100% !important;">=0A              <!--[if (!mso)=
&(!IE)]><!--><div style=3D"border-top: 0px solid transparent; bor=
der-left: 0px solid transparent; border-bottom: 0px solid transpa=
rent; border-right: 0px solid transparent; padding-top:10px; padd=
ing-bottom:5px; padding-right: 0px; padding-left: 0px;"><!--<![en=
dif]-->=0A=0A                  =0A                    <div align=3D=
"center" class=3D"img-container center fixedwidth " style=3D"padd=
ing-right: 0px;  padding-left: 0px;">=0A<!--[if mso]><table width=
=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><tr st=
yle=3D"line-height:0px;line-height:0px;"><td style=3D"padding-rig=
ht: 0px; padding-left: 0px;" align=3D"center"><![endif]-->=0A  <a=
 href=3D"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D121661&t=
p=3Di-H43-6W-3Yb-K3A8Z-1c-GneT-1c-K2bgq-pmFM8" target=3D"_blank">=
=0A    <img class=3D"center fixedwidth" align=3D"center" border=3D=
"0" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/images/w_abo=
ut2x_new.gif" alt=3D"About Atlantis" title=3D"About Atlantis" sty=
le=3D"outline: none;text-decoration: none;-ms-interpolation-mode:=
 bicubic;clear: both;display: block !important;border: none;heigh=
t: auto;float: none;width: 100%;max-width: 170px" width=3D"170">=0A=
  </a>=0A<!--[if mso]></td></tr></table><![endif]-->=0A</div>=0A=0A=
                  =0A              <!--[if (!mso)&(!IE)]><!--></d=
iv><!--<![endif]-->=0A              </div>=0A            </div>=0A=
              <!--[if (mso)|(IE)]></td><td align=3D"center" width=
=3D"200" style=3D" width:200px; padding-right: 0px; padding-left:=
 0px; padding-top:10px; padding-bottom:5px; border-top: 0px solid=
 transparent; border-left: 0px solid transparent; border-bottom: =
0px solid transparent; border-right: 0px solid transparent;" vali=
gn=3D"top"><![endif]-->=0A            <div class=3D"col num4" sty=
le=3D"max-width: 320px;min-width: 200px;display: table-cell;verti=
cal-align: top;">=0A              <div style=3D"background-color:=
 transparent; width: 100% !important;">=0A              <!--[if (=
!mso)&(!IE)]><!--><div style=3D"border-top: 0px solid transparent=
; border-left: 0px solid transparent; border-bottom: 0px solid tr=
ansparent; border-right: 0px solid transparent; padding-top:10px;=
 padding-bottom:5px; padding-right: 0px; padding-left: 0px;"><!--=
<![endif]-->=0A=0A                  =0A                    <div a=
lign=3D"center" class=3D"img-container center fixedwidth " style=3D=
"padding-right: 0px;  padding-left: 0px;">=0A<!--[if mso]><table =
width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><=
tr style=3D"line-height:0px;line-height:0px;"><td style=3D"paddin=
g-right: 0px; padding-left: 0px;" align=3D"center"><![endif]-->=0A=
  <a href=3D"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D1216=
62&tp=3Di-H43-6W-3Yb-K3A8Z-1c-GneT-1c-K2bgq-pmFM8" target=3D"_bla=
nk">=0A    <img class=3D"center fixedwidth" align=3D"center" bord=
er=3D"0" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/images/=
w_blog2x_new.gif" alt=3D"Atlantis Blog" title=3D"Atlantis Blog" s=
tyle=3D"outline: none;text-decoration: none;-ms-interpolation-mod=
e: bicubic;clear: both;display: block !important;border: none;hei=
ght: auto;float: none;width: 100%;max-width: 170px" width=3D"170"=
>=0A  </a>=0A<!--[if mso]></td></tr></table><![endif]-->=0A</div>=
=0A=0A                  =0A              <!--[if (!mso)&(!IE)]><!=
--></div><!--<![endif]-->=0A              </div>=0A            </=
div>=0A          <!--[if (mso)|(IE)]></td></tr></table></td></tr>=
</table><![endif]-->=0A        </div>=0A      </div>=0A    </div>=
=0A    <div style=3D"background-color:transparent;">=0A      <div=
 style=3D"Margin: 0 auto;min-width: 320px;max-width: 600px;overfl=
ow-wrap: break-word;word-wrap: break-word;word-break: break-word;=
background-color: transparent;" class=3D"block-grid ">=0A        =
<div style=3D"border-collapse: collapse;display: table;width: 100=
%;background-color:transparent;">=0A          <!--[if (mso)|(IE)]=
><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=
=3D"0"><tr><td style=3D"background-color:transparent;" align=3D"c=
enter"><table cellpadding=3D"0" cellspacing=3D"0" border=3D"0" st=
yle=3D"width: 600px;"><tr class=3D"layout-full-width" style=3D"ba=
ckground-color:transparent;"><![endif]-->=0A=0A              <!--=
[if (mso)|(IE)]><td align=3D"center" width=3D"600" style=3D" widt=
h:600px; padding-right: 0px; padding-left: 0px; padding-top:5px; =
padding-bottom:5px; border-top: 0px solid transparent; border-lef=
t: 0px solid transparent; border-bottom: 0px solid transparent; b=
order-right: 0px solid transparent;" valign=3D"top"><![endif]-->=0A=
            <div class=3D"col num12" style=3D"min-width: 320px;ma=
x-width: 600px;display: table-cell;vertical-align: top;">=0A     =
         <div style=3D"background-color: transparent; width: 100%=
 !important;">=0A              <!--[if (!mso)&(!IE)]><!--><div st=
yle=3D"border-top: 0px solid transparent; border-left: 0px solid =
transparent; border-bottom: 0px solid transparent; border-right: =
0px solid transparent; padding-top:5px; padding-bottom:5px; paddi=
ng-right: 0px; padding-left: 0px;"><!--<![endif]-->=0A=0A        =
          =0A                    <div class=3D"">=0A<!--[if mso]>=
<table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D=
"0"><tr><td style=3D"padding-right: 10px; padding-left: 10px; pad=
ding-top: 20px; padding-bottom: 20px;"><![endif]-->=0A<div style=3D=
"color:#555555;font-family:Verdana, Geneva, sans-serif;line-heigh=
t:120%; padding-right: 10px; padding-left: 10px; padding-top: 20p=
x; padding-bottom: 20px;">=0A<div style=3D"font-size:12px;line-he=
ight:14px;color:#555555;font-family:Verdana, Geneva, sans-serif;t=
ext-align:left;"><p style=3D"margin: 0;font-size: 14px;line-heigh=
t: 17px;text-align: center"><span style=3D"font-size: 12px; line-=
height: 14px; color: rgb(136, 136, 136);">Terms &amp; Conditions =
apply. </span><br><br><span style=3D"font-size: 12px; line-height=
: 14px; color: rgb(136, 136, 136);">Copyright 2018, Atlantis, Ker=
zner P.O. Box 211222, UAE, Atlantis The Palm. </span><br><br><spa=
n style=3D"font-size: 12px; line-height: 14px; color: rgb(136, 13=
6, 136);">To unsubscribe from this Atlantis, The Palm list please=
 click <a style=3D"text-decoration: none; color: #888888;" href=3D=
"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D121663&tp=3Di-H4=
3-6W-3Yb-K3A8Z-1c-GneT-1c-K2bgq-pmFM8&x=3Di-H43-6W-3Yb-K3A8Z-1c-G=
neT-1c-K2bgq-pmFM8" target=3D"_blank" rel=3D"noopener"><span styl=
e=3D"color: rgb(51, 51, 51); font-size: 12px; line-height: 14px;"=
><strong>here</strong></span></a>. </span><br><br><span style=3D"=
font-size: 12px; line-height: 14px; color: rgb(136, 136, 136);">R=
eview Atlantis, The Palm <span style=3D"color: rgb(51, 51, 51); f=
ont-size: 12px; line-height: 14px;"><strong><a style=3D"color:#3C=
3C3C;text-decoration: none;" href=3D"http://l.e.atlantisthepalm.c=
om/rts/go2.aspx?h=3D121664&tp=3Di-H43-6W-3Yb-K3A8Z-1c-GneT-1c-K2b=
gq-pmFM8" target=3D"_blank" rel=3D"noopener">Privacy Policy</a></=
strong></span> and <span style=3D"color: rgb(0, 0, 0); font-size:=
 12px; line-height: 14px;"><a style=3D"color:#3C3C3C;text-decorat=
ion: none;" href=3D"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=
=3D121665&tp=3Di-H43-6W-3Yb-K3A8Z-1c-GneT-1c-K2bgq-pmFM8" target=3D=
"_blank" rel=3D"noopener"><span style=3D"font-size: 12px; line-he=
ight: 14px;"><strong>Terms and Conditions</strong></span></a></sp=
an>. </span><br><br><span style=3D"font-size: 12px; line-height: =
14px; color: rgb(136, 136, 136);">Please do not reply to this ema=
il.</span></p></div>=0A</div>=0A<!--[if mso]></td></tr></table><!=
[endif]-->=0A</div>=0A                  =0A                  =0A =
                   <div align=3D"center" class=3D"img-container c=
enter fixedwidth " style=3D"padding-right: 0px;  padding-left: 0p=
x;">=0A<!--[if mso]><table width=3D"100%" cellpadding=3D"0" cells=
pacing=3D"0" border=3D"0"><tr style=3D"line-height:0px;line-heigh=
t:0px;"><td style=3D"padding-right: 0px; padding-left: 0px;" alig=
n=3D"center"><![endif]-->=0A  <a href=3D"http://l.e.atlantisthepa=
lm.com/rts/go2.aspx?h=3D121658&tp=3Di-H43-6W-3Yb-K3A8Z-1c-GneT-1c=
-K2bgq-pmFM8" target=3D"_blank">=0A    <img class=3D"center fixed=
width" align=3D"center" border=3D"0" src=3D"http://wpm.ccmp.eu/wp=
m/404/ContentUploads/images/w_logo2x_.gif" alt=3D"Atlantis the pa=
lm" title=3D"Atlantis the palm" style=3D"outline: none;text-decor=
ation: none;-ms-interpolation-mode: bicubic;clear: both;display: =
block !important;border: none;height: auto;float: none;width: 100=
%;max-width: 180px" width=3D"180">=0A  </a>=0A<div style=3D"line-=
height:20px;font-size:1px">&#160;</div><!--[if mso]></td></tr></t=
able><![endif]-->=0A</div>=0A=0A                  =0A            =
  <!--[if (!mso)&(!IE)]><!--></div><!--<![endif]-->=0A           =
   </div>=0A            </div>=0A          <!--[if (mso)|(IE)]></=
td></tr></table></td></tr></table><![endif]-->=0A        </div>=0A=
      </div>=0A    </div>=0A   <!--[if (mso)|(IE)]></td></tr></ta=
ble><![endif]-->=0A</td>=0A  </tr>=0A  </tbody>=0A  </table>=0A  =
<!--[if (mso)|(IE)]></div><![endif]-->=0A=0A</body>=0A    =0A</ht=
ml>

