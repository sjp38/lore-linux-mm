Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9F94C10F13
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 03:18:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88CBC20880
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 03:18:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="qPxHoQrB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88CBC20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2D316B0008; Mon,  8 Apr 2019 23:18:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDCA36B000C; Mon,  8 Apr 2019 23:18:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCD976B0010; Mon,  8 Apr 2019 23:18:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9FEFB6B0008
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 23:18:10 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o1so8272812pgv.15
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 20:18:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=jBEr9KpoXXYFgFcdLwqasRo12XkN4IbExkA0ZDwKwVw=;
        b=JBolBTz/lVYAwnaNuKVcqu8xIBFUUA8neabWeyX0IpSJPMEGVn05xoqWbhK/nSsEU4
         kMZrlXylDsmyBkB8IkcDXQR9EG/q05DgmO9XFpB3xye3iBSd/MKeLXeq2dKH2kAd4xT7
         TBOemB47Jdmu3KLobaNUmEvRcMUaN/TJNm4huSvGcTlMtCAZg88k2UdZljg5J2toyB77
         eDv+/VR8IU0GbogX0cLjpdIN8qnIw5eCSL2r8iGQx+xw+ttobHdQp3VXKd8BjesLM81e
         3bp77HkMx32AqQKVnSUYD6AKyfRG6agUh9zk94v2Wf6LwXwG1JZlt+sWZ6pukpOyk2Rv
         DStQ==
X-Gm-Message-State: APjAAAVvfXhi2aWnGZ6DJU28FUX8aJuEtOpjhf5/jTYP6tmn2Rp5bOm+
	7+Uh4nSzkLKP9k3RS+dF79ijFpM7dBCdnmqeGHg7bsx60RChhvVK59qnHQf70L14RdEn865hkZe
	V/AjjXHYDnBw/WtdviCIYLetuFOHt+UUiu5VRun4E0W3vErAit287AWsxNLyKuhp4sw==
X-Received: by 2002:a62:5582:: with SMTP id j124mr34224784pfb.53.1554779890225;
        Mon, 08 Apr 2019 20:18:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+MJ/JQEC4tElcakf0tb4YOrDvy3+gx/+XmmAhMHsgM26VgYZ3H8oegB21J3nDGjlJNIiq
X-Received: by 2002:a62:5582:: with SMTP id j124mr34224748pfb.53.1554779889501;
        Mon, 08 Apr 2019 20:18:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554779889; cv=none;
        d=google.com; s=arc-20160816;
        b=hdDMKLModDfAUldGK7kh+Ytu2V7CmRAkSRUt3A2qG1l9nJSjoH9XnemuZQcqYHBrzH
         FQRApgpLUk+WVCG5ZkUOkW7ODZZCbqSlB1QL+Auv4jHcEtSM+3FGnmKqww+a12406NGy
         +NCR9Ztx7IWQrNgVPXA83gnnRRqGSPgMEA5ZUpU9kzWi2xUdIdnKGbs8EWmidWrSTBbw
         CAbcx3pB05I+nlpVJrlMXDq0PT7mJsDkHueKYJgWGzjX7rSp32Z8J/HWW25BG73ZQVYC
         yLgSbnOqEq2idH+wXoEsaXG8gFuPVOpCqb8OQFjymoKfE5yW2LnflATCEYfbO9thYo8h
         jyFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=jBEr9KpoXXYFgFcdLwqasRo12XkN4IbExkA0ZDwKwVw=;
        b=gOjt3j1/6aZT+N2u6qaSwDnhJtz+HZ8AwiIKwUPx3bEHWYN2JtQBnh6cDOaLtxY0Xy
         DHXpjcr5QZPHPt6KuJXyZyIikbTe2+jP+BBbd4/TUSMIezDotLismOjgRgLNGi6QUe53
         CGKliriDV85hqPiMyURkpmO7SGHHsoXd9HloHpwQiPZLCTXjSeKvwWco6uGk2C4USrGA
         MsAsAvhfqzFTb1p0CMBGvjyxKPGnocdMBjG8nqScv9f8/TAiuL0l3GCM3rjcuxX0jk5n
         /9fuoOteNCUDu1fdgr9VZKhs+4QuZHIE61jo+Po/dgTe8UahUhYsJRt3mfJ8R3rPFpLX
         3WNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qPxHoQrB;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id t10si27616570plr.229.2019.04.08.20.18.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 20:18:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qPxHoQrB;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3934sXf134961;
	Tue, 9 Apr 2019 03:18:07 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=jBEr9KpoXXYFgFcdLwqasRo12XkN4IbExkA0ZDwKwVw=;
 b=qPxHoQrBKAB1BW7whygSvj4xi7L10edhI7Pi54VSf9OJHg2wAokUFXHwQNIkn3YMSou2
 lEmvFLtUS66S9yLKni1RD/jmF1D6jBjolc4B9sljYOSzobOvYFUmM15+22z6btJNxPaY
 Ker0U0emieDLVTqZwi5PSaYGmI5Ow0xXB02jsImSfU4x1EQ4xnmDPbTGllDyiJ2sUCI3
 as47Uisrp86eXY+NoNckvL63Dw689kQcMaNfKSQGz86U+/eEpaF7qKrencP7CW3ORSRV
 N37exHDCmxBdcASQt03JdfMKtjm2N8/UCYaJDSaAm0wmPTG3ura9jrJeJpNELQEPZMh4 eA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2130.oracle.com with ESMTP id 2rphmeabnv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 09 Apr 2019 03:18:06 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x393I5PH127162;
	Tue, 9 Apr 2019 03:18:06 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2rph7sbdsb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 09 Apr 2019 03:18:05 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x393I32T025291;
	Tue, 9 Apr 2019 03:18:03 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 08 Apr 2019 20:18:03 -0700
Date: Mon, 8 Apr 2019 20:18:01 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-xfs <linux-xfs@vger.kernel.org>,
        Linux MM <linux-mm@kvack.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Ext4 <linux-ext4@vger.kernel.org>,
        Linux Btrfs <linux-btrfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] xfs: don't allow most setxattr to immutable files
Message-ID: <20190409031801.GD5147@magnolia>
References: <155466882175.633834.15261194784129614735.stgit@magnolia>
 <155466884962.633834.14320700092446721044.stgit@magnolia>
 <CAOQ4uxj4WLX8sWbnm11Ps+rmCNTPecV-w9YUzJfKDtDs+qTx3Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxj4WLX8sWbnm11Ps+rmCNTPecV-w9YUzJfKDtDs+qTx3Q@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9221 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=857
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904090021
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9221 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=880 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904090020
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 08, 2019 at 09:20:47AM +0300, Amir Goldstein wrote:
> On Sun, Apr 7, 2019 at 11:28 PM Darrick J. Wong <darrick.wong@oracle.com> wrote:
> >
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> >
> > The chattr manpage has this to say about immutable files:
> >
> > "A file with the 'i' attribute cannot be modified: it cannot be deleted
> > or renamed, no link can be created to this file, most of the file's
> > metadata can not be modified, and the file can not be opened in write
> > mode."
> >
> > However, we don't actually check the immutable flag in the setattr code,
> > which means that we can update project ids and extent size hints on
> > supposedly immutable files.  Therefore, reject a setattr call on an
> > immutable file except for the case where we're trying to unset
> > IMMUTABLE.
> >
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Did you miss my comment on v1, or do you not think this use case
> is going to hurt any application that is not a rootkit?
> 
> chattr +i foo => OK
> chattr +i foo => -EPERM

Nah, I plain forgot to update the patch. :(

Will send v2 where you're allowed to +i multiple times so long as that's
the only thing you're changing.

--D

> Thanks,
> Amir.

