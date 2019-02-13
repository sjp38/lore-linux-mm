Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6EEEC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:54:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F23F222A4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:54:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F23F222A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A57E8E0002; Wed, 13 Feb 2019 16:54:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12F188E0001; Wed, 13 Feb 2019 16:54:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEB3D8E0002; Wed, 13 Feb 2019 16:54:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A77978E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:54:24 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o9so2629787pgv.19
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 13:54:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=cuRX7H0FRf69bDHIoNZZwguThmQM4wQmhCuOvzdmw4k=;
        b=Oxa6/vuSYFZnZ1vcPbdUzPsfdJ4Fsq6twichXWEliALWN65zmK9PwIcPgZAHpB3Fe7
         VTo7briOJVSzW8MaeB/r/h3vMRiCi8UCsna1m9IPsG+UnESvFNnSvu8dC8nY1jlmLjXH
         alK7YZGD2rq3NRkaLISdE6QBSZiRuPS9Sme18mRT9yTrziR4VUdtlAZ02HEeVG4jKoxR
         thrkVaE2YfTk0f3mN/hZUGaGAvfuL/vwFZpIZE/iGbX23I+bHodXEowU7PgWW6EjT71h
         7D/pdIYUhKvH7HoEWuwDHKpMOJNFbTHOKPTBebsbkKQ0bqWO9hWYexprGYKue1+1mbHF
         Dz3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZU0McWjfRJKtACyTnsYVZKE3t2ZgNxiYha3dOekb33+8SXFNX5
	pVOaV3TDaya98FIdB3mti1RPjk3EfQjoiukRfoYWQVkEaaxW9IGkXWTKsP10eCl0+oxJGr7cgeb
	QoBqasmm73cekg8XuRunmIVyqBjMn9EYBauNzx+NZ/+oFiNAUT+Fo8hTYFdW0jOsKgw==
X-Received: by 2002:a17:902:4d46:: with SMTP id o6mr359753plh.302.1550094864357;
        Wed, 13 Feb 2019 13:54:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbTZl7OyKktP26heQpMmflIUp3lBsZA/m5I1AV9gWntrc5GqS3iHD3N95QDGwaH2sHFEjjW
X-Received: by 2002:a17:902:4d46:: with SMTP id o6mr359714plh.302.1550094863725;
        Wed, 13 Feb 2019 13:54:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550094863; cv=none;
        d=google.com; s=arc-20160816;
        b=w8NFvA8pvGG3hWgylFR2SCAwlR+HLDY7aMPbbzZedJHND6z7qDIhiIwzq5uLkZbgUD
         /m18i4x68NcjgNSzKdsJMleY9o3NPengR4dPzuzvSgg4f2aB1VYoA2M2ZYWOxSqXZ8Wh
         0yNCsVfDM94kogkb/f+TzTKmrFgBRe5FsLyMqW+S/sdVS8ds4ThK333Ch9g1EzRo51gR
         ukgjTSEbx6EkzRo2hh2PH4ZjZP3EqOa5x0k0bfR2Y+QrcY7nJFaSeLec4vmLdy/Q4E9b
         y+5N/wXYQqj4wN+M0brEx4Rx0HrjVQXo+1sk/5V48kAy+vTzrMsbg1xgoNWyGv/Y1svV
         S8pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=cuRX7H0FRf69bDHIoNZZwguThmQM4wQmhCuOvzdmw4k=;
        b=ovhAtNa18D7KZsbvyTIwpgOzPQ1y4EOCa3EoJ4lXrClwYvz0cXUjIY1tgJp+MN8zkp
         EjQ2Yw80HszZsf8P6u1CscATVc5BuAZejkcWzJlFUzXlRvjvTrYlaxmOWgzqpAAzbKJr
         pkxBCuox7OoH2KtDSIGdO9YofuMsG75sMim31bkoiI3MYaMDQpJvAR30tPKXQIcakzJG
         XS9qg3XQg0n5S2gAwp3sS43S/iOAi26KtR0z0ew+4rC/39k9RKpft10WrAdUPrHDWSbO
         T/f3gCviQN9mm8rM1PKEwLCy3UqDHiqPMltFMAUvXMlE7VDM/ddEA0TCr5CLNjANzCak
         fBJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t74si435846pgc.150.2019.02.13.13.54.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 13:54:23 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1DLrlUP058628
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:54:23 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qmt753ae8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:54:22 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 13 Feb 2019 21:54:20 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 13 Feb 2019 21:54:15 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1DLsEiG54460644
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 13 Feb 2019 21:54:14 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7E4D5A404D;
	Wed, 13 Feb 2019 21:54:14 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6AC9AA4057;
	Wed, 13 Feb 2019 21:54:13 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.163])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 13 Feb 2019 21:54:13 +0000 (GMT)
Date: Wed, 13 Feb 2019 23:54:11 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Russell King <linux@armlinux.org.uk>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>, Guan Xuetao <gxt@pku.edu.cn>,
        linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
        linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: initramfs tidyups
References: <20190213174621.29297-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213174621.29297-1-hch@lst.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021321-0008-0000-0000-000002C02702
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021321-0009-0000-0000-0000222C470E
Message-Id: <20190213215411.GF15270@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-13_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=433 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902130144
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 06:46:13PM +0100, Christoph Hellwig wrote:
> Hi all,
> 
> I've spent some time chasing down behavior in initramfs and found
> plenty of opportunity to improve the code.  A first stab on that is
> contained in this series.
 
For the series:

Acked-by: Mike Rapoport <rppt@linux.ibm.com>

-- 
Sincerely yours,
Mike.

