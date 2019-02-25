Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DACA8C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 21:21:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A180821848
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 21:21:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A180821848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D4E28E0005; Mon, 25 Feb 2019 16:21:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4828E8E0004; Mon, 25 Feb 2019 16:21:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 372F38E0005; Mon, 25 Feb 2019 16:21:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE94B8E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:21:55 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id x5so3000440plv.17
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:21:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=BG5P5Y3EhTktL30NcCasfWNNo/88mNxKfignN2ua/X4=;
        b=s6cmfrr1UE2x1FyA1JgfDSEv8dmxoBePyzvTl5zLaati5iEwOKaGKK3RH/00wRrh/L
         /AEJP3oGxzVzaA31uRTP/E0n8EP9/GzdGh1t9F/EnhcMLJYLshdhY+Sl2xhVk21gDb3E
         sJ1BiHpdAgeiIRjAG3LRrFNzPZw749mZ5l6y3v/meBrPvClvd3c+C/LJmIYRD+B0bd/Q
         QEY3L4s4DNAmVe+POZrckDpD05dQ8g9DaHRyPuLWoUPYRa6UzRqnub0PnZSNOHejVtAm
         PUshz8M2c6gleCdWDlLzGnL9tt8+CQHiamsCogrm3GK4p0i1hUGCwPOv/mlCozy2voLE
         TOXg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZ9rHoMeFGxHtmGfjVWfTZF/0dKpFjTgx6jXWITFsAYKuI5rDDc
	XYqvczcHXTaQXzIpUwA2YLjXaFOzSlvZPJ3pOdx2TVFqYtTE1XtyD1W3bA3wW3tAtIfrnVlpDRK
	QPiE1aC89YjtupHeyfMSNO/vZBAgRAnk1/JFyZflS4ic+WOovQZ7CmTGUaEKBB2xc+Q==
X-Received: by 2002:aa7:8042:: with SMTP id y2mr22252523pfm.39.1551129715656;
        Mon, 25 Feb 2019 13:21:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iaex5aE0Tyv6VyfNhE72Gr5sa+MMtifr+3+5w543cPL/90HGY8vlIhJoc0oAxOM1/qi4mN4
X-Received: by 2002:aa7:8042:: with SMTP id y2mr22252482pfm.39.1551129714921;
        Mon, 25 Feb 2019 13:21:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551129714; cv=none;
        d=google.com; s=arc-20160816;
        b=KwiT9Z0kpYZGAqceai0F0MzHgUiG5dHmk3muUgt0wcMLv78hJE9APRcKn04CU5btsS
         Jj7okNSYCA1P5AeDQa8nZaxfHvGliT9I8+XirCipdk/a12D2Y4NTl4mPLRG+gqk8IXNR
         8/tlCS1OVIAh73BbPnkARh7SD6I/f0kBPQq76RfF5Z9Mr4VMSrZZqNreuT8wCo5u8YjW
         fdZQUtL/cTyVwHZA5o2zh4IABA9gzBKynqdhZaf6VB9GSbN2m+non8JRgYF0kqMkMVjY
         U450qROF5bl8iEuUXNp8KcUiy2ZQ2Ah1kA4jPH11BlpomW+zc/spy2clpPLYnF/n2BqB
         SMXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=BG5P5Y3EhTktL30NcCasfWNNo/88mNxKfignN2ua/X4=;
        b=SEXCmr5kMhTbyV/YxUlfQ5sYNWg+Gxhycu3mPt6YGr1hW5sWkx3omzRd0pJbiDlMBo
         +c/CqeOcEY3o4pFfFX32qeIy1UfaVG566LDMkkZL+5oKYRFMU4C3zJR8b68rmHTfGhd9
         wyMZ0IfgqXTiAInPwh5ZTWVdlEZkHtqav4XTpO6JAWypiYaCzDXwJHAKd7r/o43JKnX/
         PYaqMtXvost4hObfeqni41I5zR+8yS5r+WLLgcnqWpNvBcjxMB3RtLqk7fJGivpdD7T8
         owCqvSlgwrGwx5aY7VoqBTRBD5ezUuSfdKeDZXENYdkvDKZ1ZJyE71f5SN7Eg7j6LWwm
         DBpg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b6si10665255pfi.20.2019.02.25.13.21.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 13:21:54 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1PL4r1C052627
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:21:54 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qvnan0drf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:21:54 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 25 Feb 2019 21:21:51 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 25 Feb 2019 21:21:48 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1PLLl4058523660
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 25 Feb 2019 21:21:48 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D1C39A4040;
	Mon, 25 Feb 2019 21:21:47 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3B7BFA4057;
	Mon, 25 Feb 2019 21:21:47 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.243])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 25 Feb 2019 21:21:47 +0000 (GMT)
Date: Mon, 25 Feb 2019 23:21:45 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: David Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] sparc64: simplify reduce_memory() function
References: <1549963956-28269-1-git-send-email-rppt@linux.ibm.com>
 <20190217082816.GB1176@rapoport-lnx>
 <20190217.101532.1280291105433517556.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190217.101532.1280291105433517556.davem@davemloft.net>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022521-0016-0000-0000-0000025AC871
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022521-0017-0000-0000-000032B527A5
Message-Id: <20190225212144.GH10454@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-25_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=661 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902250151
X-Bogosity: Ham, tests=bogofilter, spamicity=0.003513, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 17, 2019 at 10:15:32AM -0800, David Miller wrote:
> From: Mike Rapoport <rppt@linux.ibm.com>
> Date: Sun, 17 Feb 2019 10:28:17 +0200
> 
> > Any comments on this?
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Can you please take it via sparc tree? 

-- 
Sincerely yours,
Mike.

