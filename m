Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F16A2C76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 09:20:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9796622BEF
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 09:20:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9796622BEF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.vnet.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB9E16B0003; Fri, 26 Jul 2019 05:20:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6C0A6B0005; Fri, 26 Jul 2019 05:20:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D58048E0002; Fri, 26 Jul 2019 05:20:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id AEED96B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:20:31 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id q196so40279748ybg.8
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 02:20:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=URmliiLio5RV59SRw/0TUvrRVe83OgfTO/1NrGrmCIo=;
        b=AzN0bhVJ0L8SB5f7aTW0CKNEAIm5NbO0sCDcPWJq1fXLMWRzPg+Svpk3LonRbr736f
         4CFm7a2khujW2pk9/mEtlQ4Fa7JokRI/4kx1ySVoYV6Tc54Oza6xL3BlRPD1OMqELu+s
         A+0sFXdthoxwuJOiexPK9nXFkSPKoFKRSfE/nyrDaOOh88IbU+OWVFPyHeBJ8Cd8ibGe
         drAFTnF0sbag+JCbkV2Oov8RHeMhk5zom7WyD/O5tRJZ8rNmkJbhhGknhEv4iW+PEceU
         jLUeIjYMyCrt9ezECGWbBlapiZBhKWMUMb1d+ujVQkXevGLF6fc6pPXOKTP5bxb1wuJE
         SFkQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXmY2T1O/8P2Ax49PTb9qYxszcCdughlfhLKHJEqIxg88CYR60k
	N7X6LtwaMmpZnRXHtfJP4/U7wC2edhDHPpqrRFjYwkUmDckg5tTo+uaecBPdJZTrodGClWfsmTQ
	q5hSOYJUAql5yki8NGqCmz8Rm2yu/YTljOWYjvGj4VkaCNX4SGbdoTURr9sa/rQM=
X-Received: by 2002:a81:1f42:: with SMTP id f63mr51087339ywf.184.1564132831432;
        Fri, 26 Jul 2019 02:20:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTCwbVr/ROjGlrAPk939iNso+uuDYGusw197vBubNDAdNETmH2VQrB+2Gd8NA7rnhVLiT8
X-Received: by 2002:a81:1f42:: with SMTP id f63mr51087309ywf.184.1564132830719;
        Fri, 26 Jul 2019 02:20:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564132830; cv=none;
        d=google.com; s=arc-20160816;
        b=Qv3lIKIdxlL2hvKAVgToY0uWM9E+LuiVi4uiiXAl1jdz7S7YoX9eJpbL/R1hO20EUX
         vmJ5zQ4Sc6PDlzkr5gqDMB6C2rVIFpl2Xs2TwCDor4uApCz5iWg079IsvKREBQCeXKBE
         PNjZdDSgIEezg8zRIJe9dsGWbhj2+6ecmaxd72rgukAgyPYxK3HohvRm/EkTGaP3Xopu
         ZEailV0dty6qQJqJm3numy8SWsVZ6IV6dwVMVrA8vM8Ynxq92NKKNtdrFjJRaInyYV4X
         ZWGfgr61DR3NnkoplEq50NASKXiHm0UV1A+OoSF3Om0+J/yn2UH7z1mY2CZzrT1T4+Ww
         8GCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=URmliiLio5RV59SRw/0TUvrRVe83OgfTO/1NrGrmCIo=;
        b=s9eX/m2FOGIgMMVaFpVV2pQmCgK47o0AdKHZoWeh1EPiAf4657TcabwwG5vrVSWGB3
         wC3ryF2p9xdrN7PzCOLfQ2X/7MFiuHKKimDFOgboCU1vghrphjjYzRdADpArtvcYDEjD
         cZSxvYv9XNPyMamw1J/6aSIwJYHszgUd4dUlurAQ/TjPHISVg/s/Kymlw6M0jbRg4vjK
         39KHqiU0LkEFU7M/bzbPFSL08COfRDjzSMy84yChawQr1kpULrKBvvm6iPYzvs9YUfNN
         F+4eS6F/HiGRBrPQVIYHXdn6IMwEJas06DGbdLLSTZaKttZgjTEkxjRBLQLdpZcR6ikc
         I4zw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 66si12821526ybu.472.2019.07.26.02.20.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 02:20:30 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6Q9HS3a008464
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:20:30 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2tywgh3r75-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:20:30 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 26 Jul 2019 10:20:28 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 26 Jul 2019 10:20:24 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6Q9KNF652559878
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 26 Jul 2019 09:20:23 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BA0C3AE051;
	Fri, 26 Jul 2019 09:20:23 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DE303AE056;
	Fri, 26 Jul 2019 09:20:21 +0000 (GMT)
Received: from linux.vnet.ibm.com (unknown [9.126.150.29])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with SMTP;
	Fri, 26 Jul 2019 09:20:21 +0000 (GMT)
Date: Fri, 26 Jul 2019 14:50:21 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>,
        jhladky@redhat.com, lvenanci@redhat.com,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND] autonuma: Fix scan period updating
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20190725080124.494-1-ying.huang@intel.com>
 <20190725173516.GA16399@linux.vnet.ibm.com>
 <87y30l5jdo.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <87y30l5jdo.fsf@yhuang-dev.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-TM-AS-GCONF: 00
x-cbid: 19072609-0016-0000-0000-0000029661A1
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19072609-0017-0000-0000-000032F46133
Message-Id: <20190726092021.GA5273@linux.vnet.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-26_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907260120
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Huang, Ying <ying.huang@intel.com> [2019-07-26 15:45:39]:

> Hi, Srikar,
> 
> >
> > More Remote + Private page Accesses:
> > Most likely the Private accesses are going to be local accesses.
> >
> > In the unlikely event of the private accesses not being local, we should
> > scan faster so that the memory and task consolidates.
> >
> > More Remote + Shared page Accesses: This means the workload has not
> > consolidated and needs to scan faster. So we need to scan faster.
> 
> This sounds reasonable.  But
> 
> lr_ratio < NUMA_PERIOD_THRESHOLD
> 
> doesn't indicate More Remote.  If Local = Remote, it is also true.  If

less lr_ratio means more remote.

> there are also more Shared, we should slow down the scanning.  So, the

Why should we slowing down if there are more remote shared accesses?

> logic could be
> 
> if (lr_ratio >= NUMA_PERIOD_THRESHOLD)
>     slow down scanning
> else if (sp_ratio >= NUMA_PERIOD_THRESHOLD) {
>     if (NUMA_PERIOD_SLOTS - lr_ratio >= NUMA_PERIOD_THRESHOLD)
>         speed up scanning
>     else
>         slow down scanning
> } else
>    speed up scanning
> 
> This follows your idea better?
> 
> Best Regards,
> Huang, Ying

-- 
Thanks and Regards
Srikar Dronamraju

