Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,MIME_HTML_ONLY,
	SPF_PASS,T_KAM_HTML_FONT_INVALID autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC91BC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 09:03:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3EDE2082F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 09:03:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=e.atlantisthepalm.com header.i=info@e.atlantisthepalm.com header.b="krdB1frk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3EDE2082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=e.atlantisthepalm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46F856B0003; Thu, 28 Mar 2019 05:03:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41DA46B0007; Thu, 28 Mar 2019 05:03:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E7B96B0008; Thu, 28 Mar 2019 05:03:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id AAA536B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 05:03:43 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id t10so10540801wrp.3
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 02:03:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:errors-to:message-id
         :list-unsubscribe:mime-version:from:to:date:subject
         :content-transfer-encoding;
        bh=yXOO2jg73eYi0umYI9MbztlFK/QdzNkdbIRx2/bvOoE=;
        b=EoFtLGC5+czA6zF8zWivYnwLlJou4oTbCl+z91iAC3rSMJd9GBt7Yc5SsoBcOn9LM/
         ODj8iTrsSBxeML+sq9bGd86M4OvtKV0NTB7UZS8sFH64+H0JSRNBG/1CdRwFUpOf5vwT
         rwnMKQtUsQNH3VNM8D6WxA0Qwt1xhEg2zD93pkn5MQ4xJ93dnb5hj5M7BQG5LPhN4xEt
         ZPSnqBrAXjyDz8Qzq1T+42ii2AcmF4zvm/fvtRi3gJNk4062T0ACSQgWZrdFuo2KWBxk
         70FjOJh0Dy04D/jrE4OW2qZUCAjDa1DQcQi5VjXBh1r8mJTfjfl+K1086+++HP0V0rzP
         1iTw==
X-Gm-Message-State: APjAAAXYOnLul9kuyRMrODdOnZAQ6b8i5noYlpDfjRn3Thi/ykqV5Dol
	5v2mYk0ysaVuW/Fnr4o/gr2stz1PQFBFRenGlgDKp+BVZtmIhrWnnYiw4tU9ssGrTDOAlhRjQ1r
	BXbUg5tS67vF1HYi8dUvWygrymEfkFi7PxYk1QKfWvFQEYYXaDl6L0Mv6hGD0eMlggg==
X-Received: by 2002:a5d:54c4:: with SMTP id x4mr25334983wrv.296.1553763823142;
        Thu, 28 Mar 2019 02:03:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlnM0A/etHPQTMe/E1+Zra6MQpUG2vIRq3JHiOWQpBijsRfB+PRRJjS4TiqeLnUE0nxEUi
X-Received: by 2002:a5d:54c4:: with SMTP id x4mr25334928wrv.296.1553763822273;
        Thu, 28 Mar 2019 02:03:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553763822; cv=none;
        d=google.com; s=arc-20160816;
        b=h4HMSS8dljJpPwGqY9Tc2hWGHEVr1x6DGyLny+2H1klqS9/7FdORTvPxGQqq/mugcU
         2s1b+bgEh27GaC9Kpzc+wZms6DgplOkGstFpOGQPXsSKjRy4fS99xgRVAZaakCDzfks/
         yTjvwkHtEgpnA0mQ1jqT0NayVPQh/D0JTEDzkZ7eAVSpWmXusrQ9eupy8OF7vGwmzIZ5
         oOKqcmuq9vsdnJ/XJvl1GwZ+os4GKVk+HleXmqJ9oD+ou0849B22b7nxlQx/tkn901B5
         z21kZMhROTe0X+mlaVhzJbYA5RP+4yBQiW51ZOxuju4oduq/gYwDxa6LZ8OrTMH+AlCd
         cEZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:subject:date:to:from:mime-version
         :list-unsubscribe:message-id:errors-to:dkim-signature;
        bh=yXOO2jg73eYi0umYI9MbztlFK/QdzNkdbIRx2/bvOoE=;
        b=UnCVLDw/zEfLQf3fUdgnEj26n63E141HD5RmoLawXHzupbp3hTD3kGy49BsYiGywgb
         gYCOC5t6YtkcZGYrut5rwwgGiK8m7XlP1HPeDVxG8XALyHBAeNWDYDZE4DPRFNgSd156
         LNaA6vhCyoVMJOcqAqp0nsvEhAW9MN1XcSm1AmThZP5vqlO2csSqUH6r4PlVSqp1agZ7
         ILwEpotNPc3Y9y+0cuLnNHzDZEhCnAlQbriYYt9H9KOtmZxvqeE0QXJRZ/BRZ440T4Cf
         OlB9T/4AZMhfVR6g1zWQ1AMK9fyGOI+a7X/W9FD44vkQ8irrmaJP9tuqwncBCJ64ZGkn
         v/Ug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@e.atlantisthepalm.com header.s=0 header.b=krdB1frk;
       spf=pass (google.com: domain of info@e.atlantisthepalm.com designates 62.144.109.110 as permitted sender) smtp.mailfrom=info@e.atlantisthepalm.com
Received: from mta109110.e.atlantisthepalm.com (mta109110.e.atlantisthepalm.com. [62.144.109.110])
        by mx.google.com with ESMTPS id b14si5316587wrr.99.2019.03.28.02.03.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 02:03:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of info@e.atlantisthepalm.com designates 62.144.109.110 as permitted sender) client-ip=62.144.109.110;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@e.atlantisthepalm.com header.s=0 header.b=krdB1frk;
       spf=pass (google.com: domain of info@e.atlantisthepalm.com designates 62.144.109.110 as permitted sender) smtp.mailfrom=info@e.atlantisthepalm.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; s=0; d=e.atlantisthepalm.com;
 h=Message-ID:List-Unsubscribe:MIME-Version:From:To:Date:Subject:Content-Type:
 Content-Transfer-Encoding; i=info@e.atlantisthepalm.com;
 bh=yXOO2jg73eYi0umYI9MbztlFK/QdzNkdbIRx2/bvOoE=;
 b=krdB1frkXKBNWNJLUhCkAVX9LoFmy24p0hT1wdYEARDkNxYljQ+owglNgiqhdzG5WgKnDTPkmHm8
   jXUvBEJ1/q9iwxYHO9eKvXGelcw9HFsc0hnkD2mDIU2WLmzoRTM1NddqiONDWKOWMXR1trdIOxuA
   2iRPtcAJ4/KZO1EYRto=
Received: by mta109110.e.atlantisthepalm.com id hji6uo2bs1kg for <linux-mm@kvack.org>; Thu, 28 Mar 2019 09:03:35 +0000 (envelope-from <info@e.atlantisthepalm.com>)
Message-ID: <404.300840170.201903280903350589179.0032640756@e.atlantisthepalm.com>
List-Unsubscribe: <mailto:unsubscribe-cd154defd019f8128fdf42e9b3b027e4@e.atlantisthepalm.com?subject=Unsubscribe>
X-Mailer: XyzMailer
X-Xyz-cr: 404
X-Xyz-cn: 14036
X-Xyz-bcn: 13951
X-Xyz-md: 100
X-Xyz-mg: 300840170
X-Xyz-et: 100
X-Xyz-pk: 4004113
X-Xyz-ct: 44072
X-Xyz-bct: 43981
MIME-Version: 1.0
From: "Atlantis, The Palm" <info@e.atlantisthepalm.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Date: 28 Mar 2019 09:03:35 +0000
Subject: Last chance to Add A Little Luxury, for less
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.246086, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "=
http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">=0A=0A=0A=
=0A<html xmlns=3D"http://www.w3.org/1999/xhtml" xmlns:o=3D"urn:sc=
hemas-microsoft-com:office:office" xmlns:v=3D"urn:schemas-microso=
ft-com:vml">=0A=0A<head>=0A=0A<!--[if gte mso 9]><xml><o:OfficeDo=
cumentSettings><o:AllowPNG/><o:PixelsPerInch>96</o:PixelsPerInch>=
</o:OfficeDocumentSettings></xml><![endif]-->=0A=0A<meta content=3D=
"text/html; charset=3Dutf-8" http-equiv=3D"Content-Type" />=0A=0A=
<meta content=3D"width=3Ddevice-width" name=3D"viewport" />=0A=0A=
<!--[if !mso]><!-->=0A=0A<meta content=3D"IE=3Dedge" http-equiv=3D=
"X-UA-Compatible" />=0A=0A<!--<![endif]-->=0A=0A<title></title>=0A=
=0A<!--[if !mso]><!-->=0A=0A<!--<![endif]-->=0A=0A<style type=3D"=
text/css">=0A=0Abody {=0A=0Amargin: 0;=0A=0Apadding: 0;=0A=0A}=0A=
=0A=0A=0Atable,=0A=0Atd,=0A=0Atr {=0A=0Avertical-align: top;=0A=0A=
border-collapse: collapse;=0A=0A}=0A=0A=0A=0A* {=0A=0Aline-height=
: inherit;=0A=0A}=0A=0A=0A=0Aa[x-apple-data-detectors=3Dtrue] {=0A=
=0Acolor: inherit !important;=0A=0Atext-decoration: none !importa=
nt;=0A=0A}=0A=0A=0A=0A.ie-browser table {=0A=0Atable-layout: fixe=
d;=0A=0A}=0A=0A=0A=0A[owa] .img-container div,=0A=0A[owa] .img-co=
ntainer button {=0A=0Adisplay: block !important;=0A=0A}=0A=0A=0A=0A=
[owa] .fullwidth button {=0A=0Awidth: 100% !important;=0A=0A}=0A=0A=
=0A=0A[owa] .block-grid .col {=0A=0Adisplay: table-cell;=0A=0Aflo=
at: none !important;=0A=0Avertical-align: top;=0A=0A}=0A=0A=0A=0A=
.ie-browser .block-grid,=0A=0A.ie-browser .num12,=0A=0A[owa] .num=
12,=0A=0A[owa] .block-grid {=0A=0Awidth: 600px !important;=0A=0A}=
=0A=0A=0A=0A.ie-browser .mixed-two-up .num4,=0A=0A[owa] .mixed-tw=
o-up .num4 {=0A=0Awidth: 200px !important;=0A=0A}=0A=0A=0A=0A.ie-=
browser .mixed-two-up .num8,=0A=0A[owa] .mixed-two-up .num8 {=0A=0A=
width: 400px !important;=0A=0A}=0A=0A=0A=0A.ie-browser .block-gri=
d.two-up .col,=0A=0A[owa] .block-grid.two-up .col {=0A=0Awidth: 3=
00px !important;=0A=0A}=0A=0A=0A=0A.ie-browser .block-grid.three-=
up .col,=0A=0A[owa] .block-grid.three-up .col {=0A=0Awidth: 300px=
 !important;=0A=0A}=0A=0A=0A=0A.ie-browser .block-grid.four-up .c=
ol [owa] .block-grid.four-up .col {=0A=0Awidth: 150px !important;=
=0A=0A}=0A=0A=0A=0A.ie-browser .block-grid.five-up .col [owa] .bl=
ock-grid.five-up .col {=0A=0Awidth: 120px !important;=0A=0A}=0A=0A=
=0A=0A.ie-browser .block-grid.six-up .col,=0A=0A[owa] .block-grid=
.six-up .col {=0A=0Awidth: 100px !important;=0A=0A}=0A=0A=0A=0A.i=
e-browser .block-grid.seven-up .col,=0A=0A[owa] .block-grid.seven=
-up .col {=0A=0Awidth: 85px !important;=0A=0A}=0A=0A=0A=0A.ie-bro=
wser .block-grid.eight-up .col,=0A=0A[owa] .block-grid.eight-up .=
col {=0A=0Awidth: 75px !important;=0A=0A}=0A=0A=0A=0A.ie-browser =
.block-grid.nine-up .col,=0A=0A[owa] .block-grid.nine-up .col {=0A=
=0Awidth: 66px !important;=0A=0A}=0A=0A=0A=0A.ie-browser .block-g=
rid.ten-up .col,=0A=0A[owa] .block-grid.ten-up .col {=0A=0Awidth:=
 60px !important;=0A=0A}=0A=0A=0A=0A.ie-browser .block-grid.eleve=
n-up .col,=0A=0A[owa] .block-grid.eleven-up .col {=0A=0Awidth: 54=
px !important;=0A=0A}=0A=0A=0A=0A.ie-browser .block-grid.twelve-u=
p .col,=0A=0A[owa] .block-grid.twelve-up .col {=0A=0Awidth: 50px =
!important;=0A=0A}=0A=0A</style>=0A=0A<style id=3D"media-query" t=
ype=3D"text/css">=0A=0A@media only screen and (min-width: 620px) =
{=0A=0A.block-grid {=0A=0Awidth: 600px !important;=0A=0A}=0A=0A=0A=
=0A.block-grid .col {=0A=0Avertical-align: top;=0A=0A}=0A=0A=0A=0A=
.block-grid .col.num12 {=0A=0Awidth: 600px !important;=0A=0A}=0A=0A=
=0A=0A.block-grid.mixed-two-up .col.num3 {=0A=0Awidth: 150px !imp=
ortant;=0A=0A}=0A=0A=0A=0A.block-grid.mixed-two-up .col.num4 {=0A=
=0Awidth: 200px !important;=0A=0A}=0A=0A=0A=0A.block-grid.mixed-t=
wo-up .col.num8 {=0A=0Awidth: 400px !important;=0A=0A}=0A=0A=0A=0A=
.block-grid.mixed-two-up .col.num9 {=0A=0Awidth: 450px !important=
;=0A=0A}=0A=0A=0A=0A.block-grid.two-up .col {=0A=0Awidth: 300px !=
important;=0A=0A}=0A=0A=0A=0A.block-grid.three-up .col {=0A=0Awid=
th: 200px !important;=0A=0A}=0A=0A=0A=0A.block-grid.four-up .col =
{=0A=0Awidth: 150px !important;=0A=0A}=0A=0A=0A=0A.block-grid.fiv=
e-up .col {=0A=0Awidth: 120px !important;=0A=0A}=0A=0A=0A=0A.bloc=
k-grid.six-up .col {=0A=0Awidth: 100px !important;=0A=0A}=0A=0A=0A=
=0A.block-grid.seven-up .col {=0A=0Awidth: 85px !important;=0A=0A=
}=0A=0A=0A=0A.block-grid.eight-up .col {=0A=0Awidth: 75px !import=
ant;=0A=0A}=0A=0A=0A=0A.block-grid.nine-up .col {=0A=0Awidth: 66p=
x !important;=0A=0A}=0A=0A=0A=0A.block-grid.ten-up .col {=0A=0Awi=
dth: 60px !important;=0A=0A}=0A=0A=0A=0A.block-grid.eleven-up .co=
l {=0A=0Awidth: 54px !important;=0A=0A}=0A=0A=0A=0A.block-grid.tw=
elve-up .col {=0A=0Awidth: 50px !important;=0A=0A}=0A=0A}=0A=0A=0A=
=0A@media (max-width: 620px) {=0A=0A=0A=0A.block-grid,=0A=0A.col =
{=0A=0Amin-width: 320px !important;=0A=0Amax-width: 100% !importa=
nt;=0A=0Adisplay: block !important;=0A=0A}=0A=0A=0A=0A.block-grid=
 {=0A=0Awidth: 100% !important;=0A=0A}=0A=0A=0A=0A.col {=0A=0Awid=
th: 100% !important;=0A=0A}=0A=0A=0A=0A.col>div {=0A=0Amargin: 0 =
auto;=0A=0A}=0A=0A=0A=0Aimg.fullwidth,=0A=0Aimg.fullwidthOnMobile=
 {=0A=0Amax-width: 100% !important;=0A=0A}=0A=0A=0A=0A.no-stack .=
col {=0A=0Amin-width: 0 !important;=0A=0Adisplay: table-cell !imp=
ortant;=0A=0A}=0A=0A=0A=0A.no-stack.two-up .col {=0A=0Awidth: 50%=
 !important;=0A=0A}=0A=0A=0A=0A.no-stack .col.num4 {=0A=0Awidth: =
33% !important;=0A=0A}=0A=0A=0A=0A.no-stack .col.num8 {=0A=0Awidt=
h: 66% !important;=0A=0A}=0A=0A=0A=0A.no-stack .col.num4 {=0A=0Aw=
idth: 33% !important;=0A=0A}=0A=0A=0A=0A.no-stack .col.num3 {=0A=0A=
width: 25% !important;=0A=0A}=0A=0A=0A=0A.no-stack .col.num6 {=0A=
=0Awidth: 50% !important;=0A=0A}=0A=0A=0A=0A.no-stack .col.num9 {=
=0A=0Awidth: 75% !important;=0A=0A}=0A=0A=0A=0A.mobile_hide {=0A=0A=
min-height: 0px;=0A=0Amax-height: 0px;=0A=0Amax-width: 0px;=0A=0A=
display: none;=0A=0Aoverflow: hidden;=0A=0Afont-size: 0px;=0A=0A}=
=0A=0A}=0A=0A</style>=0A=0A</head>=0A=0A<body class=3D"clean-body=
" style=3D"margin: 0; padding: 0; -webkit-text-size-adjust: 100%;=
 background-color: #FFFFFF;"><img src=3D"http://l.e.atlantisthepa=
lm.com/rts/open.aspx?tp=3Di-H43-6W-3eO-KMIGo-1c-GneT-1c-KM1vD-1XK=
kiZ" height=3D"1" width=3D"1" style=3D"display:none"><table width=
=3D"1" height=3D"1" cellpadding=3D"0" cellspacing=3D"0" border=3D=
"0">=0A  <tr><td style=3D"font-size:0px; line-height:0px;">=0A   =
 <img src=3D"http://mi.atlantisthepalm.com/p/cp/04513604bf633298/=
o.gif?mi_u=3D%%UID%%" width=3D"1" height=3D"1" alt=3D"" aria-hidd=
en=3D"true" />=0A  </td></tr>=0A</table>=0A=0A=0A<style id=3D"med=
ia-query-bodytag" type=3D"text/css">=0A=0A@media (max-width: 620p=
x) {=0A=0A  .block-grid {=0A=0A    min-width: 320px!important;=0A=
=0A    max-width: 100%!important;=0A=0A    width: 100%!important;=
=0A=0A    display: block!important;=0A=0A  }=0A=0A  .col {=0A=0A =
   min-width: 320px!important;=0A=0A    max-width: 100%!important=
;=0A=0A    width: 100%!important;=0A=0A    display: block!importa=
nt;=0A=0A  }=0A=0A  .col > div {=0A=0A    margin: 0 auto;=0A=0A  =
}=0A=0A  img.fullwidth {=0A=0A    max-width: 100%!important;=0A=0A=
    height: auto!important;=0A=0A  }=0A=0A  img.fullwidthOnMobile=
 {=0A=0A    max-width: 100%!important;=0A=0A    height: auto!impo=
rtant;=0A=0A  }=0A=0A  .no-stack .col {=0A=0A    min-width: 0!imp=
ortant;=0A=0A    display: table-cell!important;=0A=0A  }=0A=0A  .=
no-stack.two-up .col {=0A=0A    width: 50%!important;=0A=0A  }=0A=
=0A  .no-stack.mixed-two-up .col.num4 {=0A=0A    width: 33%!impor=
tant;=0A=0A  }=0A=0A  .no-stack.mixed-two-up .col.num8 {=0A=0A   =
 width: 66%!important;=0A=0A  }=0A=0A  .no-stack.three-up .col.nu=
m4 {=0A=0A    width: 33%!important=0A=0A  }=0A=0A  .no-stack.four=
-up .col.num3 {=0A=0A    width: 25%!important=0A=0A  }=0A=0A}=0A=0A=
</style>=0A=0A<!--[if IE]><div class=3D"ie-browser"><![endif]-->=0A=
=0A<table bgcolor=3D"#FFFFFF" cellpadding=3D"0" cellspacing=3D"0"=
 class=3D"nl-container" style=3D"table-layout: fixed; vertical-al=
ign: top; min-width: 320px; Margin: 0 auto; border-spacing: 0; bo=
rder-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace:=
 0pt; background-color: #FFFFFF; width: 100%;" valign=3D"top" wid=
th=3D"100%">=0A=0A<tbody>=0A=0A<tr style=3D"vertical-align: top;"=
 valign=3D"top">=0A=0A    <td style=3D"word-break: break-word; ve=
rtical-align: top; border-collapse: collapse;" valign=3D"top">=0A=
=0A=0A        <!--[if (mso)|(IE)]><table width=3D"100%" cellpaddi=
ng=3D"0" cellspacing=3D"0" border=3D"0"><tr><td align=3D"center" =
style=3D"background-color:#FFFFFF"><![endif]-->=0A=0A=0A        <=
div style=3D"background-color:#FFFFFF;">=0A=0A=0A            <div=
 class=3D"block-grid" style=3D"Margin: 0 auto; min-width: 320px; =
max-width: 600px; overflow-wrap: break-word; word-wrap: break-wor=
d; word-break: break-word; background-color: transparent;;">=0A=0A=
=0A                <div style=3D"border-collapse: collapse;displa=
y: table;width: 100%;background-color:transparent;">=0A=0A=0A    =
                <!--[if (mso)|(IE)]><table width=3D"100%" cellpad=
ding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"background-col=
or:#FFFFFF;"><tr><td align=3D"center"><table cellpadding=3D"0" ce=
llspacing=3D"0" border=3D"0" style=3D"width:600px"><tr class=3D"l=
ayout-full-width" style=3D"background-color:transparent"><![endif=
]-->=0A                    <!--[if (mso)|(IE)]><td align=3D"cente=
r" width=3D"600" style=3D"background-color:transparent;width:600p=
x; border-top: 0px solid transparent; border-left: 0px solid tran=
sparent; border-bottom: 0px solid transparent; border-right: 0px =
solid transparent;" valign=3D"top"><table width=3D"100%" cellpadd=
ing=3D"0" cellspacing=3D"0" border=3D"0"><tr><td style=3D"padding=
-right: 0px; padding-left: 0px; padding-top:5px; padding-bottom:5=
px;"><![endif]-->=0A=0A=0A                    <div class=3D"col n=
um12" style=3D"min-width: 320px; max-width: 600px; display: table=
-cell; vertical-align: top;;">=0A=0A=0A                        <d=
iv style=3D"width:100% !important;">=0A=0A=0A                    =
        <!--[if (!mso)&(!IE)]><!-->=0A=0A=0A                     =
       <div style=3D"border-top:0px solid transparent; border-lef=
t:0px solid transparent; border-bottom:0px solid transparent; bor=
der-right:0px solid transparent; padding-top:5px; padding-bottom:=
5px; padding-right: 0px; padding-left: 0px;">=0A=0A=0A           =
                     <!--<![endif]-->=0A                         =
       <!--[if mso]><table width=3D"100%" cellpadding=3D"0" cells=
pacing=3D"0" border=3D"0"><tr><td style=3D"padding-right: 10px; p=
adding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-=
family: Verdana, sans-serif"><![endif]-->=0A=0A=0A               =
                 <div style=3D"color:#555555;font-family:Verdana,=
 Geneva, sans-serif;line-height:120%;padding-top:10px;padding-rig=
ht:10px;padding-bottom:10px;padding-left:10px;">=0A=0A=0A        =
                            <div style=3D"font-size: 12px; line-h=
eight: 14px; color: #555555; font-family: Verdana, Geneva, sans-s=
erif;">=0A=0A=0A                                        <p style=3D=
"font-size: 14px; line-height: 14px; text-align: center; margin: =
0;"><span style=3D"font-size: 12px;">Up to 35% OFF Imperial Club =
- View the <span style=3D"color: #333333; font-size: 12px; line-h=
eight: 14px;"><strong><a href=3D"http://l.e.atlantisthepalm.com/r=
ts/go2.aspx?h=3D123507&tp=3Di-H43-6W-3eO-KMIGo-1c-GneT-1c-KM1vD-1=
XKkiZ&x=3Dcd154defd019f8128fdf42e9b3b027e4" rel=3D"noopener" styl=
e=3D"text-decoration: none; color: #333333;" target=3D"_blank">we=
b version</a></strong></span></span></p>=0A=0A=0A                =
                    </div>=0A=0A=0A                              =
  </div>=0A=0A=0A                                <!--[if mso]></t=
d></tr></table><![endif]-->=0A                                <!-=
-[if (!mso)&(!IE)]><!-->=0A=0A=0A                            </di=
v>=0A=0A=0A                            <!--<![endif]-->=0A=0A=0A =
                       </div>=0A=0A=0A                    </div>=0A=
=0A=0A                    <!--[if (mso)|(IE)]></td></tr></table><=
![endif]-->=0A                    <!--[if (mso)|(IE)]></td></tr><=
/table></td></tr></table><![endif]-->=0A=0A=0A                </d=
iv>=0A=0A=0A            </div>=0A=0A=0A        </div>=0A=0A=0A   =
     <div style=3D"background-color:transparent;">=0A=0A=0A      =
      <div class=3D"block-grid" style=3D"Margin: 0 auto; min-widt=
h: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap:=
 break-word; word-break: break-word; background-color: transparen=
t;;">=0A=0A=0A                <div style=3D"border-collapse: coll=
apse;display: table;width: 100%;background-color:transparent;">=0A=
=0A=0A                    <!--[if (mso)|(IE)]><table width=3D"100=
%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"back=
ground-color:transparent;"><tr><td align=3D"center"><table cellpa=
dding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"width:600px">=
<tr class=3D"layout-full-width" style=3D"background-color:transpa=
rent"><![endif]-->=0A                    <!--[if (mso)|(IE)]><td =
align=3D"center" width=3D"600" style=3D"background-color:transpar=
ent;width:600px; border-top: 0px solid transparent; border-left: =
0px solid transparent; border-bottom: 0px solid transparent; bord=
er-right: 0px solid transparent;" valign=3D"top"><table width=3D"=
100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><tr><td st=
yle=3D"padding-right: 0px; padding-left: 0px; padding-top:15px; p=
adding-bottom:15px;"><![endif]-->=0A=0A=0A                    <di=
v class=3D"col num12" style=3D"min-width: 320px; max-width: 600px=
; display: table-cell; vertical-align: top;;">=0A=0A=0A          =
              <div style=3D"width:100% !important;">=0A=0A=0A    =
                        <!--[if (!mso)&(!IE)]><!-->=0A=0A=0A     =
                       <div style=3D"border-top:0px solid transpa=
rent; border-left:0px solid transparent; border-bottom:0px solid =
transparent; border-right:0px solid transparent; padding-top:15px=
; padding-bottom:15px; padding-right: 0px; padding-left: 0px;">=0A=
=0A=0A                                <!--<![endif]-->=0A=0A=0A  =
                              <div align=3D"center" class=3D"img-=
container center fixedwidth" style=3D"padding-right: 0px;padding-=
left: 0px;">=0A=0A=0A                                    <!--[if =
mso]><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" bo=
rder=3D"0"><tr style=3D"line-height:0px"><td style=3D"padding-rig=
ht: 0px;padding-left: 0px;" align=3D"center"><![endif]--><a href=3D=
"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D123508&tp=3Di-H4=
3-6W-3eO-KMIGo-1c-GneT-1c-KM1vD-1XKkiZ" target=3D"_blank"> <img a=
lign=3D"center" alt=3D"Atlantis the palm" border=3D"0" class=3D"c=
enter fixedwidth" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUpload=
s/images/w_logo2x_.gif" style=3D"outline: none; text-decoration: =
none; -ms-interpolation-mode: bicubic; clear: both; height: auto;=
 float: none; border: none; width: 100%; max-width: 150px; displa=
y: block;" title=3D"Atlantis the palm" width=3D"150" /></a>=0A=0A=
=0A                                    <!--[if mso]></td></tr></t=
able><![endif]-->=0A=0A=0A                                </div>=0A=
=0A=0A                                <!--[if (!mso)&(!IE)]><!-->=
=0A=0A=0A                            </div>=0A=0A=0A             =
               <!--<![endif]-->=0A=0A=0A                        <=
/div>=0A=0A=0A                    </div>=0A=0A=0A                =
    <!--[if (mso)|(IE)]></td></tr></table><![endif]-->=0A        =
            <!--[if (mso)|(IE)]></td></tr></table></td></tr></tab=
le><![endif]-->=0A=0A=0A                </div>=0A=0A=0A          =
  </div>=0A=0A=0A        </div>=0A=0A        <div style=3D"backgr=
ound-color:transparent;">=0A            <div class=3D"block-grid"=
 style=3D"Margin: 0 auto; min-width: 320px; max-width: 600px; ove=
rflow-wrap: break-word; word-wrap: break-word; word-break: break-=
word; background-color: transparent;;">=0A                <div st=
yle=3D"border-collapse: collapse;display: table;width: 100%;backg=
round-color:transparent;">=0A                    <!--[if (mso)|(I=
E)]><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" bor=
der=3D"0" style=3D"background-color:transparent;"><tr><td align=3D=
"center"><table cellpadding=3D"0" cellspacing=3D"0" border=3D"0" =
style=3D"width:600px"><tr class=3D"layout-full-width" style=3D"ba=
ckground-color:transparent"><![endif]-->=0A                    <!=
--[if (mso)|(IE)]><td align=3D"center" width=3D"600" style=3D"bac=
kground-color:transparent;width:600px; border-top: 0px solid tran=
sparent; border-left: 0px solid transparent; border-bottom: 0px s=
olid transparent; border-right: 0px solid transparent;" valign=3D=
"top"><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" b=
order=3D"0"><tr><td style=3D"padding-right: 0px; padding-left: 0p=
x; padding-top:0px; padding-bottom:0px;background-color:#9a8e66;"=
><![endif]-->=0A                    <div class=3D"col num12" styl=
e=3D"min-width: 320px; max-width: 600px; display: table-cell; ver=
tical-align: top;;">=0A                        <div style=3D"back=
ground-color:#9a8e66;width:100% !important;">=0A                 =
           <!--[if (!mso)&(!IE)]><!-->=0A                        =
    <div style=3D"border-top:0px solid transparent; border-left:0=
px solid transparent; border-bottom:0px solid transparent; border=
-right:0px solid transparent; padding-top:0px; padding-bottom:0px=
; padding-right: 0px; padding-left: 0px;">=0A                    =
            <!--<![endif]-->=0A                                <!=
--[if mso]><table width=3D"100%" cellpadding=3D"0" cellspacing=3D=
"0" border=3D"0"><tr><td style=3D"padding-right: 45px; padding-le=
ft: 45px; padding-top: 15px; padding-bottom: 15px; font-family: A=
rial, sans-serif"><![endif]-->=0A                                =
<a href=3D"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D123509=
&tp=3Di-H43-6W-3eO-KMIGo-1c-GneT-1c-KM1vD-1XKkiZ" target=3D"_blan=
k">=0A                                    <img align=3D"center" a=
lt=3D"spring-sale" border=3D"0" class=3D"center autowidth fullwid=
th" src=3D"http://mi.atlantisthepalm.com/p/rp/2bc048fadafebe3b.pn=
g?mi_u=3D%%UID%%" style=3D"outline: none; text-decoration: none; =
-ms-interpolation-mode: bicubic; clear: both; height: auto; float=
: none; border: none; width: 100%; max-width: 600px; display: blo=
ck;" title=3D"spring-sale" width=3D"600" />=0A                   =
             </a>=0A                                <!--[if mso]>=
</td></tr></table><![endif]-->=0A                                =
<!--[if (!mso)&(!IE)]><!-->=0A                            </div>=0A=
                            <!--<![endif]-->=0A                  =
      </div>=0A                    </div>=0A                    <=
!--[if (mso)|(IE)]></td></tr></table><![endif]-->=0A             =
       <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><!=
[endif]-->=0A                </div>=0A            </div>=0A      =
  </div>=0A=0A=0A        <div style=3D"background-color:transpare=
nt;">=0A=0A=0A            <div class=3D"block-grid" style=3D"Marg=
in: 0 auto; min-width: 320px; max-width: 600px; overflow-wrap: br=
eak-word; word-wrap: break-word; word-break: break-word; backgrou=
nd-color: #9a8e66;;">=0A=0A=0A                <div style=3D"borde=
r-collapse: collapse;display: table;width: 100%;background-color:=
#9a8e66;">=0A=0A=0A                    <!--[if (mso)|(IE)]><table=
 width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0" =
style=3D"background-color:transparent;"><tr><td align=3D"center">=
<table cellpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"=
width:600px"><tr class=3D"layout-full-width" style=3D"background-=
color:#9a8e66"><![endif]-->=0A                    <!--[if (mso)|(=
IE)]><td align=3D"center" width=3D"600" style=3D"background-color=
:#9a8e66;width:600px; border-top: 0px solid transparent; border-l=
eft: 0px solid transparent; border-bottom: 0px solid transparent;=
 border-right: 0px solid transparent;" valign=3D"top"><table widt=
h=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><tr><=
td style=3D"padding-right: 0px; padding-left: 0px; padding-top:0p=
x; padding-bottom:0px;"><![endif]-->=0A=0A=0A                    =
<div class=3D"col num12" style=3D"min-width: 320px; max-width: 60=
0px; display: table-cell; vertical-align: top;;">=0A=0A=0A       =
                 <div style=3D"width:100% !important;">=0A=0A=0A =
                           <!--[if (!mso)&(!IE)]><!-->=0A=0A=0A  =
                          <div style=3D"border-top:0px solid tran=
sparent; border-left:0px solid transparent; border-bottom:0px sol=
id transparent; border-right:0px solid transparent; padding-top:0=
px; padding-bottom:0px; padding-right: 0px; padding-left: 0px;">=0A=
=0A=0A                                <!--<![endif]-->=0A=0A=0A  =
                              <div align=3D"center" class=3D"img-=
container center autowidth fullwidth" style=3D"padding-right: 0px=
;padding-left: 0px;">=0A=0A=0A                                   =
 <!--[if mso]><table width=3D"100%" cellpadding=3D"0" cellspacing=
=3D"0" border=3D"0"><tr style=3D"line-height:0px"><td style=3D"pa=
dding-right: 0px;padding-left: 0px;" align=3D"center"><![endif]--=
><a href=3D"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D12350=
8&tp=3Di-H43-6W-3eO-KMIGo-1c-GneT-1c-KM1vD-1XKkiZ" target=3D"_bla=
nk"> <img align=3D"center" alt=3D"spring-sale" border=3D"0" class=
=3D"center autowidth fullwidth" src=3D"http://wpm.ccmp.eu/wpm/404=
/ContentUploads/images/img/SpringBlossom_LastChance_Hero.jpg" sty=
le=3D"outline: none; text-decoration: none; -ms-interpolation-mod=
e: bicubic; clear: both; height: auto; float: none; border: none;=
 width: 100%; max-width: 600px; display: block;" title=3D"spring-=
sale" width=3D"600" /></a>=0A=0A=0A                              =
      <!--[if mso]></td></tr></table><![endif]-->=0A=0A=0A       =
                         </div>=0A=0A=0A                         =
       <!--[if (!mso)&(!IE)]><!-->=0A=0A=0A                      =
      </div>=0A=0A=0A                            <!--<![endif]-->=
=0A=0A=0A                        </div>=0A=0A=0A                 =
   </div>=0A=0A=0A                    <!--[if (mso)|(IE)]></td></=
tr></table><![endif]-->=0A                    <!--[if (mso)|(IE)]=
></td></tr></table></td></tr></table><![endif]-->=0A=0A=0A       =
         </div>=0A=0A=0A            </div>=0A=0A=0A        </div>=
=0A=0A=0A        <div style=3D"background-color:transparent;">=0A=
=0A=0A            <div class=3D"block-grid" style=3D"Margin: 0 au=
to; min-width: 320px; max-width: 600px; overflow-wrap: break-word=
; word-wrap: break-word; word-break: break-word; background-color=
: #9a8e66;">=0A=0A=0A                <div style=3D"border-collaps=
e: collapse;display: table;width: 100%;background-color:#9a8e66;"=
>=0A=0A=0A                    <!--[if (mso)|(IE)]><table width=3D=
"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"=
background-color:transparent;"><tr><td align=3D"center"><table ce=
llpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"width:600=
px"><tr class=3D"layout-full-width" style=3D"background-color:#9a=
8e66"><![endif]-->=0A                    <!--[if (mso)|(IE)]><td =
align=3D"center" width=3D"600" style=3D"background-color:#9a8e66;=
width:600px; border-top: 0px solid transparent; border-left: 0px =
solid transparent; border-bottom: 0px solid transparent; border-r=
ight: 0px solid transparent;" valign=3D"top"><table width=3D"100%=
" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><tr><td style=3D=
"padding-right: 30px; padding-left: 30px; padding-top:30px; paddi=
ng-bottom:30px;"><![endif]-->=0A=0A=0A                    <div cl=
ass=3D"col num12" style=3D"min-width: 320px; max-width: 600px; di=
splay: table-cell; vertical-align: top;;">=0A=0A=0A              =
          <div style=3D"width:100% !important;">=0A=0A=0A        =
                    <!--[if (!mso)&(!IE)]><!-->=0A=0A=0A         =
                   <div style=3D"border-top:0px solid transparent=
; border-left:0px solid transparent; border-bottom:0px solid tran=
sparent; border-right:0px solid transparent; padding-top:30px; pa=
dding-bottom:30px; padding-right: 30px; padding-left: 30px;">=0A=0A=
=0A                                <!--<![endif]-->=0A           =
                     <!--[if mso]><table width=3D"100%" cellpaddi=
ng=3D"0" cellspacing=3D"0" border=3D"0"><tr><td style=3D"padding-=
right: 10px; padding-left: 10px; padding-top: 10px; padding-botto=
m: 10px; font-family: Verdana, sans-serif"><![endif]-->=0A=0A=0A =
                               <div style=3D"color:#fff;font-fami=
ly:Verdana, Geneva, sans-serif;line-height:120%;padding-top:10px;=
padding-right:10px;padding-bottom:10px;padding-left:10px;">=0A=0A=
=0A                                    <div style=3D"font-size: 1=
2px; line-height: 14px; color: #fff; font-family: Verdana, Geneva=
, sans-serif;">=0A=0A=0A                                        <=
p style=3D"font-size: 15px; line-height: 18px; text-align: center=
; margin: 0;"><span style=3D"font-size: 15px;">This is your last =
chance, so don&#39;t miss out on a little added luxury that will =
make your Atlantis, The Palm stay truly unforgettable with up to =
<strong>35% off Imperial Club</strong> when you sign up</span><br=
 />as a member.<br /><br /><span style=3D"line-height: 18px; font=
-size: 15px;">And, to make your vacation even more special, we ar=
e giving you a</span><br /><span style=3D"line-height: 18px; font=
-size: 15px;"><strong>FREE upgrade</strong> from an Imperial Club=
 King to an Imperial Club Queen Room!</span><br /><br /><span sty=
le=3D"line-height: 18px; font-size: 15px;"> With <strong>extra sa=
vings</strong> for stays between <strong>5-12 April</strong>, wha=
t are you waiting for?=0A=0A=0A=0A                               =
     </span></p></div>=0A=0A=0A                                </=
div>=0A=0A=0A                                <!--[if mso]></td></=
tr></table><![endif]-->=0A=0A=0A                                <=
div align=3D"center" class=3D"button-container" style=3D"padding-=
top:30px;padding-right:10px;padding-bottom:10px;padding-left:10px=
;">=0A=0A=0A                                    <!--[if mso]><tab=
le width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0=
" style=3D"border-spacing: 0; border-collapse: collapse; mso-tabl=
e-lspace:0pt; mso-table-rspace:0pt;"><tr><td style=3D"padding-top=
: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: =
10px" align=3D"center"><v:roundrect xmlns:v=3D"urn:schemas-micros=
oft-com:vml" xmlns:w=3D"urn:schemas-microsoft-com:office:word" hr=
ef=3D"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D123510&tp=3D=
i-H43-6W-3eO-KMIGo-1c-GneT-1c-KM1vD-1XKkiZ" style=3D"height:24pt;=
 width:69pt; v-text-anchor:middle;" arcsize=3D"0%" stroke=3D"fals=
e" fillcolor=3D"#ffffff"><w:anchorlock/><v:textbox inset=3D"0,0,0=
,0"><center style=3D"color:#9a8e66; font-family:Verdana, sans-ser=
if; font-size:12px"><![endif]--><a href=3D"http://l.e.atlantisthe=
palm.com/rts/go2.aspx?h=3D123508&tp=3Di-H43-6W-3eO-KMIGo-1c-GneT-=
1c-KM1vD-1XKkiZ" style=3D"-webkit-text-size-adjust: none; text-de=
coration: none; display: inline-block; color: #9a8e66; background=
-color: #ffffff; border-radius: 0px; -webkit-border-radius: 0px; =
-moz-border-radius: 0px; width: auto; width: auto; border-top: 1p=
x solid #ffffff; border-right: 1px solid #ffffff; border-bottom: =
1px solid #ffffff; border-left: 1px solid #ffffff; padding-top: 0=
px; padding-bottom: 0px; font-family: Verdana, Geneva, sans-serif=
; text-align: center; mso-border-alt: none; word-break: keep-all;=
" target=3D"_blank">=0A                                        <s=
pan style=3D"padding-left:5px;padding-right:5px;font-size:12px;di=
splay:inline-block;width:auto;min-width:150px;max-width:150px;hei=
ght:30px;min-height:30px;max-height:30px;">=0A=0A=0A             =
                               <span style=3D"font-size: 16px; li=
ne-height: 32px;"><strong><span style=3D"font-size: 12px; line-he=
ight: 24px;">BOOK NOW</span></strong></span>=0A=0A=0A            =
                            </span>=0A                           =
         </a>=0A=0A=0A                                    <!--[if=
 mso]></center></v:textbox></v:roundrect></td></tr></table><![end=
if]-->=0A=0A=0A                                </div>=0A=0A=0A   =
                             <!--[if (!mso)&(!IE)]><!-->=0A=0A=0A=
                            </div>=0A=0A=0A                      =
      <!--<![endif]-->=0A=0A=0A                        </div>=0A=0A=
=0A                    </div>=0A=0A=0A                    <!--[if=
 (mso)|(IE)]></td></tr></table><![endif]-->=0A                   =
 <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif=
]-->=0A=0A=0A                </div>=0A=0A=0A            </div>=0A=
=0A=0A        </div>=0A=0A=0A        <div style=3D"background-col=
or:transparent;">=0A=0A=0A            <div class=3D"block-grid" s=
tyle=3D"Margin: 0 auto; min-width: 320px; max-width: 600px; overf=
low-wrap: break-word; word-wrap: break-word; word-break: break-wo=
rd; background-color: transparent;;">=0A=0A=0A                <di=
v style=3D"border-collapse: collapse;display: table;width: 100%;b=
ackground-color:transparent;">=0A=0A=0A                    <!--[i=
f (mso)|(IE)]><table width=3D"100%" cellpadding=3D"0" cellspacing=
=3D"0" border=3D"0" style=3D"background-color:transparent;"><tr><=
td align=3D"center"><table cellpadding=3D"0" cellspacing=3D"0" bo=
rder=3D"0" style=3D"width:600px"><tr class=3D"layout-full-width" =
style=3D"background-color:transparent"><![endif]-->=0A           =
         <!--[if (mso)|(IE)]><td align=3D"center" width=3D"600" s=
tyle=3D"background-color:transparent;width:600px; border-top: 0px=
 solid transparent; border-left: 0px solid transparent; border-bo=
ttom: 0px solid transparent; border-right: 0px solid transparent;=
" valign=3D"top"><table width=3D"100%" cellpadding=3D"0" cellspac=
ing=3D"0" border=3D"0"><tr><td style=3D"padding-right: 0px; paddi=
ng-left: 0px; padding-top:15px; padding-bottom:5px;"><![endif]-->=
=0A=0A=0A                    <div class=3D"col num12" style=3D"mi=
n-width: 320px; max-width: 600px; display: table-cell; vertical-a=
lign: top;;">=0A=0A=0A                        <div style=3D"width=
:100% !important;">=0A=0A=0A                            <!--[if (=
!mso)&(!IE)]><!-->=0A=0A=0A                            <div style=
=3D"border-top:0px solid transparent; border-left:0px solid trans=
parent; border-bottom:0px solid transparent; border-right:0px sol=
id transparent; padding-top:15px; padding-bottom:5px; padding-rig=
ht: 0px; padding-left: 0px;">=0A=0A=0A                           =
     <!--<![endif]-->=0A                                <!--[if m=
so]><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" bor=
der=3D"0"><tr><td style=3D"padding-right: 10px; padding-left: 10p=
x; padding-top: 10px; padding-bottom: 10px; font-family: Verdana,=
 sans-serif"><![endif]-->=0A=0A=0A                               =
 <div style=3D"color:#555555;font-family:Verdana, Geneva, sans-se=
rif;line-height:120%;padding-top:10px;padding-right:10px;padding-=
bottom:10px;padding-left:10px;">=0A=0A=0A                        =
            <div style=3D"font-size: 12px; line-height: 14px; col=
or: #555555; font-family: Verdana, Geneva, sans-serif;">=0A=0A=0A=
                                        <p style=3D"font-size: 12=
px; line-height: 28px; text-align: center; margin: 0;"><span styl=
e=3D"font-size: 24px; color: #0065a2;">Tell my friends</span></p>=
=0A=0A=0A                                    </div>=0A=0A=0A     =
                           </div>=0A=0A=0A                       =
         <!--[if mso]></td></tr></table><![endif]-->=0A=0A=0A    =
                            <div style=3D"font-size:16px;text-ali=
gn:center;font-family:Verdana, Geneva, sans-serif">=0A=0A=0A     =
                               <div class=3D"our-class">=0A=0A=0A=
                                        <table align=3D"center" b=
order=3D"0" cellpadding=3D"0" cellspacing=3D"0">=0A=0A=0A        =
                                    <tbody>=0A=0A=0A             =
                                   <tr>=0A=0A=0A                 =
                                   <td><a href=3D"http://l.e.atla=
ntisthepalm.com/rts/go2.aspx?h=3D123511&tp=3Di-H43-6W-3eO-KMIGo-1=
c-GneT-1c-KM1vD-1XKkiZ" target=3D"_blank"><img alt=3D"facebook" b=
order=3D"0" height=3D"30" src=3D"http://wpm.ccmp.eu/wpm/404/Conte=
ntUploads/images/w_facebook2x_.gif" width=3D"30" /></a></td>=0A=0A=
=0A                                                    <td><img b=
order=3D"0" height=3D"20" src=3D"http://wpm.ccmp.eu/wpm/404/Conte=
ntUploads/images/t.gif" style=3D"display:block;" width=3D"10" /><=
/td>=0A=0A=0A                                                    =
<td><a href=3D"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D12=
3512&tp=3Di-H43-6W-3eO-KMIGo-1c-GneT-1c-KM1vD-1XKkiZ" target=3D"_=
blank"><img alt=3D"linkedin" border=3D"0" height=3D"30" src=3D"ht=
tp://wpm.ccmp.eu/wpm/404/ContentUploads/images/w_linkedin2x_.gif"=
 width=3D"30" /></a></td>=0A=0A=0A                               =
                     <td><img border=3D"0" height=3D"20" src=3D"h=
ttp://wpm.ccmp.eu/wpm/404/ContentUploads/images/t.gif" style=3D"d=
isplay:block;" width=3D"10" /></td>=0A=0A=0A                     =
                               <td><a href=3D"http://l.e.atlantis=
thepalm.com/rts/go2.aspx?h=3D123513&tp=3Di-H43-6W-3eO-KMIGo-1c-Gn=
eT-1c-KM1vD-1XKkiZ" target=3D"_blank"><img alt=3D"twitter" border=
=3D"0" height=3D"30" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUpl=
oads/images/w_twitter2x_.gif" width=3D"30" /></a></td>=0A=0A=0A  =
                                                  <td><img border=
=3D"0" height=3D"20" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUpl=
oads/images/t.gif" style=3D"display:block;" width=3D"10" /></td>=0A=
=0A=0A                                                    <td>=0A=
                                                        <a href=3D=
"http://mi.atlantisthepalm.com/p/cp/04513604bf633298/c?subject=3D=
Atlantis%20Spring%20Sale%20is%20now%20on%21&body=3D&mi_u=3D%%UID%=
%&url=3Dmailto%3A=0A=0A=0A=0Ahttp://mi.atlantisthepalm.com/p/cp/0=
4513604bf633298/c?mi_u=3D%%UID%%&url=3DUp%2520to%252030%2525%2520=
off%2520rooms%21%2520Book%2520now%2520at%2520atlantisthepalm.com%=
2Fsale%250A%250Ahttp%253A%252F%252Fx.e.atlantisthepalm.com%252Fat=
s%252Fsocial.aspx%253Ftp%253Di-H43-6W-3eO-KMIGo-1c-GneT-1c-KM1vD-=
1XKkiZ" target=3D"_blank"><img alt=3D"sms" border=3D"0" src=3D"ht=
tp://wpm.ccmp.eu/wpm/404/ContentUploads/images/w_mailto2x_.gif" w=
idth=3D"30" /></a>=0A                                            =
        </td>=0A=0A=0A                                           =
     </tr>=0A=0A=0A                                            </=
tbody>=0A=0A=0A                                        </table>=0A=
=0A=0A                                    </div>=0A=0A=0A        =
                        </div>=0A=0A=0A                          =
      <!--[if (!mso)&(!IE)]><!-->=0A=0A=0A                       =
     </div>=0A=0A=0A                            <!--<![endif]-->=0A=
=0A=0A                        </div>=0A=0A=0A                    =
</div>=0A=0A=0A                    <!--[if (mso)|(IE)]></td></tr>=
</table><![endif]-->=0A                    <!--[if (mso)|(IE)]></=
td></tr></table></td></tr></table><![endif]-->=0A=0A=0A          =
      </div>=0A=0A=0A            </div>=0A=0A=0A        </div>=0A=
=0A=0A        <div style=3D"background-color:transparent;">=0A=0A=
=0A            <div class=3D"block-grid three-up" style=3D"Margin=
: 0 auto; min-width: 320px; max-width: 600px; overflow-wrap: brea=
k-word; word-wrap: break-word; word-break: break-word; background=
-color: transparent;;">=0A=0A=0A                <div style=3D"bor=
der-collapse: collapse;display: table;width: 100%;background-colo=
r:transparent;">=0A=0A=0A                    <!--[if (mso)|(IE)]>=
<table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D=
"0" style=3D"background-color:transparent;"><tr><td align=3D"cent=
er"><table cellpadding=3D"0" cellspacing=3D"0" border=3D"0" style=
=3D"width:600px"><tr class=3D"layout-full-width" style=3D"backgro=
und-color:transparent"><![endif]-->=0A                    <!--[if=
 (mso)|(IE)]><td align=3D"center" width=3D"200" style=3D"backgrou=
nd-color:transparent;width:200px; border-top: 0px solid transpare=
nt; border-left: 0px solid transparent; border-bottom: 0px solid =
transparent; border-right: 0px solid transparent;" valign=3D"top"=
><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=
=3D"0"><tr><td style=3D"padding-right: 0px; padding-left: 0px; pa=
dding-top:10px; padding-bottom:5px;"><![endif]-->=0A=0A=0A       =
             <div class=3D"col num4" style=3D"max-width: 320px; m=
in-width: 200px; display: table-cell; vertical-align: top;;">=0A=0A=
=0A                        <div style=3D"width:100% !important;">=
=0A=0A=0A                            <!--[if (!mso)&(!IE)]><!-->=0A=
=0A=0A                            <div style=3D"border-top:0px so=
lid transparent; border-left:0px solid transparent; border-bottom=
:0px solid transparent; border-right:0px solid transparent; paddi=
ng-top:10px; padding-bottom:5px; padding-right: 0px; padding-left=
: 0px;">=0A=0A=0A                                <!--<![endif]-->=
=0A=0A=0A                                <div align=3D"center" cl=
ass=3D"img-container center fixedwidth" style=3D"padding-right: 0=
px;padding-left: 0px;">=0A=0A=0A                                 =
   <!--[if mso]><table width=3D"100%" cellpadding=3D"0" cellspaci=
ng=3D"0" border=3D"0"><tr style=3D"line-height:0px"><td style=3D"=
padding-right: 0px;padding-left: 0px;" align=3D"center"><![endif]=
--><a href=3D"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D123=
516&tp=3Di-H43-6W-3eO-KMIGo-1c-GneT-1c-KM1vD-1XKkiZ" target=3D"_b=
lank"> <img align=3D"center" alt=3D"Atlantis Live Cam" border=3D"=
0" class=3D"center fixedwidth" src=3D"http://wpm.ccmp.eu/wpm/404/=
ContentUploads/images/w_livecam2x_new.gif" style=3D"outline: none=
; text-decoration: none; -ms-interpolation-mode: bicubic; clear: =
both; height: auto; float: none; border: none; width: 100%; max-w=
idth: 170px; display: block;" title=3D"Atlantis Live Cam" width=3D=
"170" /></a>=0A=0A=0A                                    <!--[if =
mso]></td></tr></table><![endif]-->=0A=0A=0A                     =
           </div>=0A=0A=0A                                <!--[if=
 (!mso)&(!IE)]><!-->=0A=0A=0A                            </div>=0A=
=0A=0A                            <!--<![endif]-->=0A=0A=0A      =
                  </div>=0A=0A=0A                    </div>=0A=0A=
=0A                    <!--[if (mso)|(IE)]></td></tr></table><![e=
ndif]-->=0A                    <!--[if (mso)|(IE)]></td><td align=
=3D"center" width=3D"200" style=3D"background-color:transparent;w=
idth:200px; border-top: 0px solid transparent; border-left: 0px s=
olid transparent; border-bottom: 0px solid transparent; border-ri=
ght: 0px solid transparent;" valign=3D"top"><table width=3D"100%"=
 cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><tr><td style=3D=
"padding-right: 0px; padding-left: 0px; padding-top:10px; padding=
-bottom:5px;"><![endif]-->=0A=0A=0A                    <div class=
=3D"col num4" style=3D"max-width: 320px; min-width: 200px; displa=
y: table-cell; vertical-align: top;;">=0A=0A=0A                  =
      <div style=3D"width:100% !important;">=0A=0A=0A            =
                <!--[if (!mso)&(!IE)]><!-->=0A=0A=0A             =
               <div style=3D"border-top:0px solid transparent; bo=
rder-left:0px solid transparent; border-bottom:0px solid transpar=
ent; border-right:0px solid transparent; padding-top:10px; paddin=
g-bottom:5px; padding-right: 0px; padding-left: 0px;">=0A=0A=0A  =
                              <!--<![endif]-->=0A=0A=0A          =
                      <div align=3D"center" class=3D"img-containe=
r center fixedwidth" style=3D"padding-right: 0px;padding-left: 0p=
x;">=0A=0A=0A                                    <!--[if mso]><ta=
ble width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"=
0"><tr style=3D"line-height:0px"><td style=3D"padding-right: 0px;=
padding-left: 0px;" align=3D"center"><![endif]--><a href=3D"http:=
//l.e.atlantisthepalm.com/rts/go2.aspx?h=3D123517&tp=3Di-H43-6W-3=
eO-KMIGo-1c-GneT-1c-KM1vD-1XKkiZ" target=3D"_blank"> <img align=3D=
"center" alt=3D"About Atlantis" border=3D"0" class=3D"center fixe=
dwidth" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/images/w=
_about2x_new.gif" style=3D"outline: none; text-decoration: none; =
-ms-interpolation-mode: bicubic; clear: both; height: auto; float=
: none; border: none; width: 100%; max-width: 170px; display: blo=
ck;" title=3D"About Atlantis" width=3D"170" /></a>=0A=0A=0A      =
                              <!--[if mso]></td></tr></table><![e=
ndif]-->=0A=0A=0A                                </div>=0A=0A=0A =
                               <!--[if (!mso)&(!IE)]><!-->=0A=0A=0A=
                            </div>=0A=0A=0A                      =
      <!--<![endif]-->=0A=0A=0A                        </div>=0A=0A=
=0A                    </div>=0A=0A=0A                    <!--[if=
 (mso)|(IE)]></td></tr></table><![endif]-->=0A                   =
 <!--[if (mso)|(IE)]></td><td align=3D"center" width=3D"200" styl=
e=3D"background-color:transparent;width:200px; border-top: 0px so=
lid transparent; border-left: 0px solid transparent; border-botto=
m: 0px solid transparent; border-right: 0px solid transparent;" v=
align=3D"top"><table width=3D"100%" cellpadding=3D"0" cellspacing=
=3D"0" border=3D"0"><tr><td style=3D"padding-right: 0px; padding-=
left: 0px; padding-top:10px; padding-bottom:5px;"><![endif]-->=0A=
=0A=0A                    <div class=3D"col num4" style=3D"max-wi=
dth: 320px; min-width: 200px; display: table-cell; vertical-align=
: top;;">=0A=0A=0A                        <div style=3D"width:100=
% !important;">=0A=0A=0A                            <!--[if (!mso=
)&(!IE)]><!-->=0A=0A=0A                            <div style=3D"=
border-top:0px solid transparent; border-left:0px solid transpare=
nt; border-bottom:0px solid transparent; border-right:0px solid t=
ransparent; padding-top:10px; padding-bottom:5px; padding-right: =
0px; padding-left: 0px;">=0A=0A=0A                               =
 <!--<![endif]-->=0A=0A=0A                                <div al=
ign=3D"center" class=3D"img-container center fixedwidth" style=3D=
"padding-right: 0px;padding-left: 0px;">=0A=0A=0A                =
                    <!--[if mso]><table width=3D"100%" cellpaddin=
g=3D"0" cellspacing=3D"0" border=3D"0"><tr style=3D"line-height:0=
px"><td style=3D"padding-right: 0px;padding-left: 0px;" align=3D"=
center"><![endif]--><a href=3D"http://l.e.atlantisthepalm.com/rts=
/go2.aspx?h=3D123518&tp=3Di-H43-6W-3eO-KMIGo-1c-GneT-1c-KM1vD-1XK=
kiZ" target=3D"_blank"> <img align=3D"center" alt=3D"Atlantis Blo=
g" border=3D"0" class=3D"center fixedwidth" src=3D"http://wpm.ccm=
p.eu/wpm/404/ContentUploads/images/w_blog2x_new.gif" style=3D"out=
line: none; text-decoration: none; -ms-interpolation-mode: bicubi=
c; clear: both; height: auto; float: none; border: none; width: 1=
00%; max-width: 170px; display: block;" title=3D"Atlantis Blog" w=
idth=3D"170" /></a>=0A=0A=0A                                    <=
!--[if mso]></td></tr></table><![endif]-->=0A=0A=0A              =
                  </div>=0A=0A=0A                                =
<!--[if (!mso)&(!IE)]><!-->=0A=0A=0A                            <=
/div>=0A=0A=0A                            <!--<![endif]-->=0A=0A=0A=
                        </div>=0A=0A=0A                    </div>=
=0A=0A=0A                    <!--[if (mso)|(IE)]></td></tr></tabl=
e><![endif]-->=0A                    <!--[if (mso)|(IE)]></td></t=
r></table></td></tr></table><![endif]-->=0A=0A=0A                =
</div>=0A=0A=0A            </div>=0A=0A=0A        </div>=0A=0A=0A=
        <div style=3D"background-color:transparent;">=0A=0A=0A   =
         <div class=3D"block-grid" style=3D"Margin: 0 auto; min-w=
idth: 320px; max-width: 600px; overflow-wrap: break-word; word-wr=
ap: break-word; word-break: break-word; background-color: transpa=
rent;;">=0A=0A=0A                <div style=3D"border-collapse: c=
ollapse;display: table;width: 100%;background-color:transparent;"=
>=0A=0A=0A                    <!--[if (mso)|(IE)]><table width=3D=
"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"=
background-color:transparent;"><tr><td align=3D"center"><table ce=
llpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"width:600=
px"><tr class=3D"layout-full-width" style=3D"background-color:tra=
nsparent"><![endif]-->=0A                    <!--[if (mso)|(IE)]>=
<td align=3D"center" width=3D"600" style=3D"background-color:tran=
sparent;width:600px; border-top: 0px solid transparent; border-le=
ft: 0px solid transparent; border-bottom: 0px solid transparent; =
border-right: 0px solid transparent;" valign=3D"top"><table width=
=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><tr><t=
d style=3D"padding-right: 0px; padding-left: 0px; padding-top:5px=
; padding-bottom:5px;"><![endif]-->=0A=0A=0A                    <=
div class=3D"col num12" style=3D"min-width: 320px; max-width: 600=
px; display: table-cell; vertical-align: top;;">=0A=0A=0A        =
                <div style=3D"width:100% !important;">=0A=0A=0A  =
                          <!--[if (!mso)&(!IE)]><!-->=0A=0A=0A   =
                         <div style=3D"border-top:0px solid trans=
parent; border-left:0px solid transparent; border-bottom:0px soli=
d transparent; border-right:0px solid transparent; padding-top:5p=
x; padding-bottom:5px; padding-right: 0px; padding-left: 0px;">=0A=
=0A=0A                                <!--<![endif]-->=0A        =
                        <!--[if mso]><table width=3D"100%" cellpa=
dding=3D"0" cellspacing=3D"0" border=3D"0"><tr><td style=3D"paddi=
ng-right: 10px; padding-left: 10px; padding-top: 20px; padding-bo=
ttom: 20px; font-family: Verdana, sans-serif"><![endif]-->=0A=0A=0A=
                                <div style=3D"color:#555555;font-=
family:Verdana, Geneva, sans-serif;line-height:120%;padding-top:2=
0px;padding-right:10px;padding-bottom:20px;padding-left:10px;">=0A=
=0A=0A                                    <div style=3D"font-size=
: 12px; line-height: 14px; color: #555555; font-family: Verdana, =
Geneva, sans-serif;">=0A=0A=0A                                   =
     <p style=3D"font-size: 14px; line-height: 14px; text-align: =
center; margin: 0;"><span style=3D"font-size: 12px; color: #88888=
8;">Terms &amp; Conditions apply. </span><br /><br /><span style=3D=
"font-size: 12px; line-height: 14px; color: #888888;">Copyright 2=
018, Atlantis, Kerzner P.O. Box 211222, UAE, Atlantis The Palm. <=
/span><br /><br /><span style=3D"font-size: 12px; line-height: 14=
px; color: #888888;">To unsubscribe from this Atlantis, The Palm =
list please click <a href=3D"http://l.e.atlantisthepalm.com/rts/g=
o2.aspx?h=3D123519&tp=3Di-H43-6W-3eO-KMIGo-1c-GneT-1c-KM1vD-1XKki=
Z&x=3Di-H43-6W-3eO-KMIGo-1c-GneT-1c-KM1vD-1XKkiZ" rel=3D"noopener=
" style=3D"text-decoration: none; color: #888888;" target=3D"_bla=
nk"><span style=3D"color: #333333; font-size: 12px; line-height: =
14px;"><strong>here</strong></span></a>. </span><br /><br /><span=
 style=3D"font-size: 12px; line-height: 14px; color: #888888;">Re=
view Atlantis, The Palm <span style=3D"color: #333333; font-size:=
 12px; line-height: 14px;"><strong><a href=3D"http://l.e.atlantis=
thepalm.com/rts/go2.aspx?h=3D123520&tp=3Di-H43-6W-3eO-KMIGo-1c-Gn=
eT-1c-KM1vD-1XKkiZ" rel=3D"noopener" style=3D"text-decoration: no=
ne; color: #3C3C3C;" target=3D"_blank">Privacy Policy</a></strong=
></span> and <span style=3D"color: #000000; font-size: 12px; line=
-height: 14px;"><a href=3D"http://l.e.atlantisthepalm.com/rts/go2=
.aspx?h=3D123521&tp=3Di-H43-6W-3eO-KMIGo-1c-GneT-1c-KM1vD-1XKkiZ"=
 rel=3D"noopener" style=3D"text-decoration: none; color: #3C3C3C;=
" target=3D"_blank"><span style=3D"font-size: 12px; line-height: =
14px;"><strong>Terms and Conditions</strong></span></a></span>. <=
/span><br /><br /><span style=3D"font-size: 12px; line-height: 14=
px; color: #888888;">Please do not reply to this email.</span></p=
>=0A=0A=0A                                    </div>=0A=0A=0A    =
                            </div>=0A=0A=0A                      =
          <!--[if mso]></td></tr></table><![endif]-->=0A=0A=0A   =
                             <div align=3D"center" class=3D"img-c=
ontainer center fixedwidth" style=3D"padding-right: 0px;padding-l=
eft: 0px;">=0A=0A=0A                                    <!--[if m=
so]><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" bor=
der=3D"0"><tr style=3D"line-height:0px"><td style=3D"padding-righ=
t: 0px;padding-left: 0px;" align=3D"center"><![endif]--><a href=3D=
"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D123508&tp=3Di-H4=
3-6W-3eO-KMIGo-1c-GneT-1c-KM1vD-1XKkiZ" target=3D"_blank"> <img a=
lign=3D"center" alt=3D"Atlantis the palm" border=3D"0" class=3D"c=
enter fixedwidth" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUpload=
s/images/w_logo2x_.gif" style=3D"outline: none; text-decoration: =
none; -ms-interpolation-mode: bicubic; clear: both; height: auto;=
 float: none; border: none; width: 100%; max-width: 180px; displa=
y: block;" title=3D"Atlantis the palm" width=3D"180" /></a>=0A=0A=
=0A                                    <div style=3D"font-size:1p=
x;line-height:20px">?</div>=0A=0A=0A                             =
       <!--[if mso]></td></tr></table><![endif]-->=0A=0A=0A      =
                          </div>=0A=0A=0A                        =
        <!--[if (!mso)&(!IE)]><!-->=0A=0A=0A                     =
       </div>=0A=0A=0A                            <!--<![endif]--=
>=0A=0A=0A                        </div>=0A=0A=0A                =
    </div>=0A=0A=0A                    <!--[if (mso)|(IE)]></td><=
/tr></table><![endif]-->=0A                    <!--[if (mso)|(IE)=
]></td></tr></table></td></tr></table><![endif]-->=0A=0A=0A      =
          </div>=0A=0A=0A            </div>=0A=0A=0A        </div=
>=0A=0A=0A        <!--[if (mso)|(IE)]></td></tr></table><![endif]=
-->=0A=0A=0A    </td>=0A=0A</tr>=0A=0A</tbody>=0A=0A</table>=0A=0A=
<!--[if (IE)]></div><![endif]-->=0A=0A</body>=0A=0A    =0A=0A</ht=
ml>=0A

