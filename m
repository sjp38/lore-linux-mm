Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7419DC4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:00:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F6A2208CB
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:00:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F6A2208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.vnet.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C05536B0006; Wed, 26 Jun 2019 02:00:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB72D8E0003; Wed, 26 Jun 2019 02:00:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA4C18E0002; Wed, 26 Jun 2019 02:00:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 897EE6B0006
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:00:47 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id l62so2713201ywb.21
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:00:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=zRgTXH8erHgHspqVeutJFdLSHkzV7230nvvZXlD6x/U=;
        b=Web3ZtsHB8A5aJBemsUbR7GsSJqJjBvEfvLMHd99ldaUP78mHWx9bo6d+ajSQZdctH
         YdcMUMwgNbuSXUYS6IkOPlQOk8N/PPFDKLoXlt+/8EOvcHHcyx3TBsFZmA6r2Jbf9qBp
         DXFX240VnCf610TfgdsA1lozdhbdJp/UKeIhOrxhfV+qoY2WLuoNtzRyn0FgKFwRND2N
         6P3A1ZHtvYj2wBhdlK/mbQWf8iduVeHKbIWcuLYORn/XsJrk6jgGf+gQr60BH7ZFSpMo
         WQgxfdu7Z7yJaBsVzAH6fjYPzAgaLfQBrWbR+iDGHHh9XO8phaJFpdKfWjJXFJsk0QB/
         jBYg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXI25crSL6civdGwtmMT6KsNK3mGDL1ZB/nUSoiiaaU3lTQAjIq
	IYDRQ3FefD0vkUfJ0iZpTiJlC/TTK6bCWgvdNE6YrxDQGD+qJQBkud90eDztV6aLHxWV6mkZEKK
	x0wChsmy4ZIppiYob0HrJ0JuLH/79F3Pq77Z0tAFMb8M6XozhCEGm2TICwbxUoL8=
X-Received: by 2002:a25:908b:: with SMTP id t11mr1581548ybl.473.1561528847315;
        Tue, 25 Jun 2019 23:00:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhgCKJadQIbkMDOo+ptGuXVLVAqcaEaODsndbIJPmkpFZKqIFsGPepraXaB6vRP8mnDmZ7
X-Received: by 2002:a25:908b:: with SMTP id t11mr1581524ybl.473.1561528846866;
        Tue, 25 Jun 2019 23:00:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561528846; cv=none;
        d=google.com; s=arc-20160816;
        b=WhTO58B5oYoArljc+5TuSirqO+DMvoYDBhTJ2WsZ81/MNiZjrylJzWIsNsixM0wVzT
         wvSJ6UJRCINiYeiC5r0p3OfrPGnTV53c/R4HDp2+2nkUB3Ji5UAYj473yeb8cCt5lFZO
         8WTZNdxx0o1jaT7nJwwaE+cFi0cA6zGjuP9c15+2Xj7FbDDFYkmguXSvvf0zZ+xnIfpA
         rsyHLypnbYIEyaW94TSlmMzPCRjDJkMvEKzIN4zjkKpvHCpll+uK1ctC/myM5n2MYrQW
         AI4tnEAamdvIqlozI0iu+K7be3PpOe49mYlgbnH7GDDqrXW7sn5ZhTJmpw28ArZowaY3
         BAtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=zRgTXH8erHgHspqVeutJFdLSHkzV7230nvvZXlD6x/U=;
        b=ttOCnK6J1lL88H8EOBlviWzEuvTyGh8OioR2vPHcx6PdP04H3OXsXz3QNh87P02gwY
         SNW/nQQHszuf5B5ChK0hhuUa1Oa+gN3dqOOmCdhD/ntHS5XGkAUCbY5r2k1qI9J/mh9Z
         J09dYJElimw6VegRYbTNivRIx0UNE3ZzniWn1Km/IP1PWf9ZeVjACkBKbyK/0K0DEaYN
         BPZhCkiPVcZ+SF/0QFfZz3PZOS3qq0WDU7oeOf6wgE2CdTQVpZsI0qTqW/GBZ71I/HE+
         AQf8pOFMpGafnEq80FaUPt+zrtLLtTfqX5OD/mgyKWQpz6pqpNgtq1N6SMynsvHYw6CM
         IW9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j6si2166488ybo.379.2019.06.25.23.00.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 23:00:46 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5Q5uhWq130059
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:00:46 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2tc13w3tun-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:00:46 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 26 Jun 2019 07:00:44 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 26 Jun 2019 07:00:41 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5Q60e0U42991826
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 06:00:40 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CCCA64204C;
	Wed, 26 Jun 2019 06:00:40 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0141E42047;
	Wed, 26 Jun 2019 06:00:39 +0000 (GMT)
Received: from linux.vnet.ibm.com (unknown [9.126.150.29])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with SMTP;
	Wed, 26 Jun 2019 06:00:38 +0000 (GMT)
Date: Wed, 26 Jun 2019 11:30:38 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        matthew.wilcox@oracle.com, kirill.shutemov@linux.intel.com,
        peterz@infradead.org, oleg@redhat.com, rostedt@goodmis.org,
        kernel-team@fb.com, william.kucharski@oracle.com
Subject: Re: [PATCH v7 4/4] uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20190625235325.2096441-1-songliubraving@fb.com>
 <20190625235325.2096441-5-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190625235325.2096441-5-songliubraving@fb.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-TM-AS-GCONF: 00
x-cbid: 19062606-4275-0000-0000-000003464FCD
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19062606-4276-0000-0000-000038565359
Message-Id: <20190626060038.GB9158@linux.vnet.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-26_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=787 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906260072
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Song Liu <songliubraving@fb.com> [2019-06-25 16:53:25]:

> This patches uses newly added FOLL_SPLIT_PMD in uprobe. This enables easy
> regroup of huge pmd after the uprobe is disabled (in next patch).
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
>  kernel/events/uprobes.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)

Looks good to me.

Reviewed-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
-- 
Thanks and Regards
Srikar Dronamraju

