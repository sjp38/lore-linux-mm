Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3ECB0C468C2
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:41:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED956206C3
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:41:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="DdQQTu+/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED956206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B75A6B0003; Mon, 10 Jun 2019 00:41:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 967C56B0266; Mon, 10 Jun 2019 00:41:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 856DB6B0269; Mon, 10 Jun 2019 00:41:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E78E6B0003
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 00:41:50 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 30so6109044pgk.16
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 21:41:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1rlW4CBK4tGHrpGFthm0IXowDU3XrX/m9jqFgg1EvJs=;
        b=l29p/Alzp8uMPV4Qj50zmb29WOsyuSm2PWFCdgcu5TbrtxymTH83EKw1KYfpkLOT2I
         pl8pKKkHTmY3s2JIQGX1ECLCy0iLboRJl5NxojB+3UO8tR3UlVoJIfZHJjQpvkzYpx3h
         lH5z1cPWkTv8vlSMsqlUKVHG+uOMes79l2w0Prq2eqTWOjgPJ8exjL5MqIuw2dZFpsBg
         6BWB98vbAq36raXcWyBbNdfl3LI5w8JXQ+MBplmWrIrUkLp3a+dF16MyfwfsHYA5rVL9
         j9yBfayZX9XEawWGfDPL5d97aKkZFU5bw5rmauw17hCeshOe02rjQPxse53WC9aznW2p
         1Lag==
X-Gm-Message-State: APjAAAWimFWv/9rojlwFVLwQSHBfiN5dvDOUI0tqkg+2yksdNunZFV5N
	Kn9tqY0oSdSMyQQaxprwqCuIZw3wldc4LezZW+nB0Q+ovdUsNH46BQQiR01TPDIGoLJmrQjHeER
	lVhU6sTcaEIevkAv3eWSjxa/MuFrrK2yF1OdHH5VFsEnCtws6GGAiA6IctpRVInJrew==
X-Received: by 2002:a63:ed13:: with SMTP id d19mr6872253pgi.100.1560141709890;
        Sun, 09 Jun 2019 21:41:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrJMhfn8hxICEQBRBrex2EstYvgJHMr9a3DGNtNWD1C7OTCAsTJ3EdiEslE68HlZPaW+Q2
X-Received: by 2002:a63:ed13:: with SMTP id d19mr6872232pgi.100.1560141709228;
        Sun, 09 Jun 2019 21:41:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560141709; cv=none;
        d=google.com; s=arc-20160816;
        b=d+T/mpL8Ub4bWl0ocCqXqOPADyx2FlJNMGkdN19m79WB00M53rdyp+vk/NcS6sUf7W
         AVqQh0BjVDg8uJzM098PzSLGgSmIdoczfdqmcoc/c7t4UtVS2PDqD/Wwgwa1RofVZOBW
         7ni8fg0d57b8Dzi3IHYxKDxw6oCJpkUa3R3cjT+wu7lNlfbyLmI6s9xYvPUWYrX7/oQY
         cdEi6rkdm/9mdRn2H8hX1OgV5z5oJbAsx1U+EWKb50xl5N9vcb16n4lTAZ/RiGEmLJSE
         aiiP1NWBK0RdX6vIKwCDu003r6tzsLDZwHyKSdl27As+3klIAECStS6iFyjoQxnlOnaE
         UCGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1rlW4CBK4tGHrpGFthm0IXowDU3XrX/m9jqFgg1EvJs=;
        b=yfY+bEUsjtkyuaSqerBCVfF6czMynXu/BbOObLcQtdR/mgICmSKPCmDkOsvoZX4fXe
         P84AnNhzEPDtMrz+35/KONYVwfulQenhJ1dosAJuatAN3zw45e11Pdam/A6mqiFFgHSP
         OyJR6AzHPp+wd7iySQX+vyUZuOs0WsdirqqXH5QDaAOFsi76QdFaV+WnrSuRxP1SRnAe
         y/DQ+5/AaHZSKBue5LVsFJEkeCXpxQMdLry3FX4PnNEZguP18pDfz8MIG+GrjIcrN05o
         LAE3eNpuhB9o1vFDymWJ6Oo9UOW9h2ueoeax+7f/bIsuvLhqUqzXg25ObwPdJNEQLZk7
         N/ow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="DdQQTu+/";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id h1si8561059pjk.71.2019.06.09.21.41.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 21:41:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="DdQQTu+/";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5A4djbq014902;
	Mon, 10 Jun 2019 04:41:48 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=1rlW4CBK4tGHrpGFthm0IXowDU3XrX/m9jqFgg1EvJs=;
 b=DdQQTu+/oZ8BF78Vl3tSsb9U84OK1y8XCqxtjn2i+ZxuHFIycqvptntC3PB3NuSjZ7tQ
 QKmjw7cLnnSLS55U/ubPkdBlIc5x+/YSrW0qZh5QMmB56/r1MWZ5KQXRl0QeVPuYri5+
 b8xUGpNJqaYNFoP8RM//vtQyCZBGgR0d2Z9NXKJp7dR9DBm8mX2EQ2sonm6F0yVTHxWd
 cL3ROZ6dfNfUUnA0SIOR+IO8zjh7UvQvrjV9SpTbsHGg/5gzVOr879aAAOa+1TNbjIZx
 DLlT37EHBXjkErOWeO8NXIvDjq5iKIJ8nShcQcyxc6zsh4mYgLzzqu28s6IQ9mMDnUfe 1w== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2t04etcn0c-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 10 Jun 2019 04:41:48 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5A4en2r188090;
	Mon, 10 Jun 2019 04:41:47 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2t04hxkmcf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 10 Jun 2019 04:41:47 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5A4fk0T009554;
	Mon, 10 Jun 2019 04:41:46 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Sun, 09 Jun 2019 21:41:45 -0700
Date: Sun, 9 Jun 2019 21:41:44 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH 1/8] mm/fs: don't allow writes to immutable files
Message-ID: <20190610044144.GA1872750@magnolia>
References: <155552786671.20411.6442426840435740050.stgit@magnolia>
 <155552787330.20411.11893581890744963309.stgit@magnolia>
 <20190610015145.GB3266@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190610015145.GB3266@mit.edu>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9283 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=748
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906100031
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9283 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=793 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906100032
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 09, 2019 at 09:51:45PM -0400, Theodore Ts'o wrote:
> On Wed, Apr 17, 2019 at 12:04:33PM -0700, Darrick J. Wong wrote:
> > diff --git a/mm/memory.c b/mm/memory.c
> > index ab650c21bccd..dfd5eba278d6 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2149,6 +2149,9 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
> >  
> >  	vmf->flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
> >  
> > +	if (vmf->vma->vm_file && IS_IMMUTABLE(file_inode(vmf->vma->vm_file)))
> > +		return VM_FAULT_SIGBUS;
> > +
> >  	ret = vmf->vma->vm_ops->page_mkwrite(vmf);
> >  	/* Restore original flags so that caller is not surprised */
> >  	vmf->flags = old_flags;
> 
> Shouldn't this check be moved before the modification of vmf->flags?
> It looks like do_page_mkwrite() isn't supposed to be returning with
> vmf->flags modified, lest "the caller gets surprised".

Yeah, I think that was a merge error during a rebase... :(

Er ... if you're still planning to take this patch through your tree,
can you move it to above the "vmf->flags = FAULT_FLAG_WRITE..." ?

--D

> 	   	     	       	      	   - Ted

