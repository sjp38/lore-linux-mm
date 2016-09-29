Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D36A26B0253
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 09:43:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l138so74974379wmg.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 06:43:22 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id v6si6318384wjy.7.2016.09.29.06.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 06:42:50 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id w84so10784890wmg.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 06:42:50 -0700 (PDT)
Date: Thu, 29 Sep 2016 15:42:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/2] mm, proc: Fix region lost in /proc/self/smaps
Message-ID: <20160929134248.GI408@dhcp22.suse.cz>
References: <1474636354-25573-1-git-send-email-robert.hu@intel.com>
 <20160923135635.GB28734@redhat.com>
 <20160923145301.GU4478@dhcp22.suse.cz>
 <20160923155351.GA1584@redhat.com>
 <20160926084616.GA28550@dhcp22.suse.cz>
 <1475154880.16655.9.camel@vmm.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475154880.16655.9.camel@vmm.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.hu@intel.com
Cc: Oleg Nesterov <oleg@redhat.com>, pbonzini@redhat.com, akpm@linux-foundation.org, dan.j.williams@intel.com, dave.hansen@intel.com, guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On Thu 29-09-16 21:14:40, Robert Hu wrote:
> On Mon, 2016-09-26 at 10:46 +0200, Michal Hocko wrote:
> > On Fri 23-09-16 17:53:51, Oleg Nesterov wrote:
> > > On 09/23, Michal Hocko wrote:
> > > >
> > > > On Fri 23-09-16 15:56:36, Oleg Nesterov wrote:
> > > > > 
> > > > > I think we can simplify this patch. And imo make it better. How about
> > > > 
> > > > it is certainly less subtle because it doesn't report "sub-vmas".
> > > > 
> > > > > 	if (last_addr) {
> > > > > 		vma = find_vma(mm, last_addr - 1);
> > > > > 		if (vma && vma->vm_start <= last_addr)
> > > > > 			vma = m_next_vma(priv, vma);
> > > > > 		if (vma)
> > > > > 			return vma;
> > > > > 	}
> > > > 
> > > > we would still miss a VMA if the last one got shrunk/split
> > > 
> > > Not sure I understand what you mean... If the last one was split
> > > we probably should not report the new vma.
> > 
> > Right, VMA split is less of a problem. I meant to say that if the
> > last_vma->vm_end got lower for whatever reason then we could miss a VMA
> > right after. We actually might want to display such a VMA because it
> > could be a completely new one. We just do not know whether it is a
> > former split with enlarged VMA or a completely new one
> > 
> > [      old VMA     ]   Hole       [   VMA    ]
> > [ old VMA   ][  New VMa    ]      [   VMA    ]
> 
> This is indeed possible. But I see this is like the last_vma enlargement
> case. I suggest we accept such missing, as we accept the enlargement
> part of last_vma is not printed.
> 
> How about we set such target:

0) consistent output can be achieved only in the single read call

> 1) no duplicate print; 2) no old vma
> missing (unless it's unmapped); 3) monotonic printing.
> We accept those newly added/changed parts between 2 partial reads is not
> printed.

OK
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
