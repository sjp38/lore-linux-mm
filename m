Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0526C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 16:42:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D3C42175B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 16:42:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D3C42175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19B7E6B0003; Thu, 21 Mar 2019 12:42:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 124F76B0006; Thu, 21 Mar 2019 12:42:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F05176B0007; Thu, 21 Mar 2019 12:42:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B47A26B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 12:42:08 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d15so3381623pgt.14
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 09:42:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=br5qUtTHfPkZ7der5zU5fA+QAsDdAKDSaPgu7B3aPiU=;
        b=pprvvFvHJFAKo9c56CsQ8jJfuUV3s8rSqtaMmYacRUzu3RzRigXIp/AJWMrbfiBVFS
         QR5yY29QG3ATv/ShQT7LQXJsVejFF8oIp4kg1ruhMY5JiDYGVn7dpzzwhXihpz9RDg7w
         W/8z9uobNNouTM6mPQTYmmhzN3+CmDo7mkUbUWdgzrF1gzeFgHNvC7tkR0js0KJR6x02
         ilCuOPi1iQ/sbU52SeZwKdn/ze4iEJUSv2teRBqGHXogw28n8DIgoOKEryilHxoewixJ
         OPeIa1veVGJGz3+JTxUlCQmRSBsQWyRux4771jxaBp5866I4fBAicIUQAC9Abf2z2Eeg
         Bemw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX3KtDqMDL8jB7Hz0LVeoRDKaWprDMihgb7XXo4ZbfppquFs5Kp
	g8Nj5yPCF0AyaZXXoFq0ENRj9zpuKyWLuIZoMoZhNQP/JVSx5rqQKwqgSSDkm8BA5wIT+Ae/RnK
	bQ9vu79azGPR9b11Q7LPj7yuwvqbZEsG5ICwE7RXTK2/SA/w17dqj2sxBicewL6m0wQ==
X-Received: by 2002:a17:902:6b48:: with SMTP id g8mr4474515plt.21.1553186528193;
        Thu, 21 Mar 2019 09:42:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3LmDcLtFoWiqZgmdUJLTkIrY14+HWiRYLZ/NIs6ZjhELjlkgXGN8BrQEdbFGq17O5XTKE
X-Received: by 2002:a17:902:6b48:: with SMTP id g8mr4474455plt.21.1553186527156;
        Thu, 21 Mar 2019 09:42:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553186527; cv=none;
        d=google.com; s=arc-20160816;
        b=AluKUlOrRi95w8KIcI6Zw7wqqYNxJXHHHJGS8dG/js5zY+tqV14ef8jCRw0P+dw2SW
         F9TiTW9MczyYaWMyTc1DVLJ11qXOsQDkVIyP+ZApTgy1WRAU1Nbf83QFWdSmEQ2YvFeA
         Zb/jUknqfiHAW1FOFh7i65GCJ20iLQIp8JQZrR5z5S8qCuAiOqfx03QHi9+r+2FtyJpf
         AGlXsI8KHcCh1+2ITFiwT8OMX489FRRnwDVsXfR4GxDCeKB/NblW2f9E2QMI7UxyLMMk
         Tw7XEfjVQCxZfUswWyuNodUVL9I16NdYcN5J1+pstNldhj/s7uIHw+ew30dykHbcerHP
         t05w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=br5qUtTHfPkZ7der5zU5fA+QAsDdAKDSaPgu7B3aPiU=;
        b=0z/sorIwVhNrjibxHlPfC7rdBgF3GEJlE1HUW+viNYQidwhH3LpgnSPMq75/9Qpf4L
         2bQTWc3XbTq2CSHFjWKI8ZLo5eXcJgzyAJWV7GO5b10QwPcbyZ5j8q5MR3+mWTkedVFC
         RmNEVpmA9Rqd3+cGfayus5x5uHY83C8DAHoC25zgVPWkbf5/KtXqCBPn7ztuHepRQRGq
         xGhWrVYhEl/OGVssaurdUqkKB6DE2v9UGjEXxDlrK6YJc4OwbCdhQF6zJlcg/OgtYXvU
         ljDL8hd8hmMnWRWTIVBAzQscRWD6BSR6tmfmNKYVfCelOTUNO184RTCeqowMvlD3LFyp
         aWvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id n20si4376107pfi.226.2019.03.21.09.42.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 09:42:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Mar 2019 09:42:06 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,253,1549958400"; 
   d="scan'208";a="157098973"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 21 Mar 2019 09:42:05 -0700
Date: Thu, 21 Mar 2019 01:40:49 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>
Subject: Re: [RESEND PATCH 0/7] Add FOLL_LONGTERM to GUP fast and use it
Message-ID: <20190321084048.GA26439@iweiny-DESK2.sc.intel.com>
References: <20190317183438.2057-1-ira.weiny@intel.com>
 <20190319151930.bab575d62fb1a33094160fe3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319151930.bab575d62fb1a33094160fe3@linux-foundation.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 03:19:30PM -0700, Andrew Morton wrote:
> On Sun, 17 Mar 2019 11:34:31 -0700 ira.weiny@intel.com wrote:
> 
> > Resending after rebasing to the latest mm tree.
> > 
> > HFI1, qib, and mthca, use get_user_pages_fast() due to it performance
> > advantages.  These pages can be held for a significant time.  But
> > get_user_pages_fast() does not protect against mapping FS DAX pages.
> > 
> > Introduce FOLL_LONGTERM and use this flag in get_user_pages_fast() which
> > retains the performance while also adding the FS DAX checks.  XDP has also
> > shown interest in using this functionality.[1]
> > 
> > In addition we change get_user_pages() to use the new FOLL_LONGTERM flag and
> > remove the specialized get_user_pages_longterm call.
> 
> It would be helpful to include your response to Christoph's question
> (http://lkml.kernel.org/r/20190220180255.GA12020@iweiny-DESK2.sc.intel.com)
> in the changelog.  Because if one person was wondering about this,
> others will likely do so.
> 
> We have no record of acks or reviewed-by's.  At least one was missed
> (http://lkml.kernel.org/r/CAOg9mSTTcD-9bCSDfC0WRYqfVrNB4TwOzL0c4+6QXi-N_Y43Vw@mail.gmail.com),
> but that is very very partial.

That is my bad.  Sorry to Mike.  And I have added him.

> 
> This patchset is fairly DAX-centered, but Dan wasn't cc'ed!

Agreed, I'm new to changing things which affect this many sub-systems and I
struggled with who should be CC'ed (get_maintainer.pl returned a very large
list  :-(.

I fear I may have cc'ed too many people, and the wrong people apparently, so
that may be affecting the review...

So again my apologies.  I don't know if Dan is going to get a chance to put a
reviewed-by on them this week but I thought I would send this note to let you
know I'm not ignoring your feedback.  Just waiting a bit before resending to
hopefully get some more acks/reviewed bys.

Thanks,
Ira

> 
> So ho hum.  I'll scoop them up and shall make the above changes to the
> [1/n] changelog, but we still have some work to do.
> 

