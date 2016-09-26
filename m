Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 430236B027F
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 04:46:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w84so76198141wmg.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 01:46:19 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id l70si7614704wmg.18.2016.09.26.01.46.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 01:46:17 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id b184so12966441wma.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 01:46:17 -0700 (PDT)
Date: Mon, 26 Sep 2016 10:46:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/2] mm, proc: Fix region lost in /proc/self/smaps
Message-ID: <20160926084616.GA28550@dhcp22.suse.cz>
References: <1474636354-25573-1-git-send-email-robert.hu@intel.com>
 <20160923135635.GB28734@redhat.com>
 <20160923145301.GU4478@dhcp22.suse.cz>
 <20160923155351.GA1584@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160923155351.GA1584@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Robert Ho <robert.hu@intel.com>, pbonzini@redhat.com, akpm@linux-foundation.org, dan.j.williams@intel.com, dave.hansen@intel.com, guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On Fri 23-09-16 17:53:51, Oleg Nesterov wrote:
> On 09/23, Michal Hocko wrote:
> >
> > On Fri 23-09-16 15:56:36, Oleg Nesterov wrote:
> > > 
> > > I think we can simplify this patch. And imo make it better. How about
> > 
> > it is certainly less subtle because it doesn't report "sub-vmas".
> > 
> > > 	if (last_addr) {
> > > 		vma = find_vma(mm, last_addr - 1);
> > > 		if (vma && vma->vm_start <= last_addr)
> > > 			vma = m_next_vma(priv, vma);
> > > 		if (vma)
> > > 			return vma;
> > > 	}
> > 
> > we would still miss a VMA if the last one got shrunk/split
> 
> Not sure I understand what you mean... If the last one was split
> we probably should not report the new vma.

Right, VMA split is less of a problem. I meant to say that if the
last_vma->vm_end got lower for whatever reason then we could miss a VMA
right after. We actually might want to display such a VMA because it
could be a completely new one. We just do not know whether it is a
former split with enlarged VMA or a completely new one

[      old VMA     ]   Hole       [   VMA    ]
[ old VMA   ][  New VMa    ]      [   VMA    ]

> Nevermind, in any case yes, sure, this can't "fix" other corner cases.

Agreed, or at least I do not see an easy way for that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
