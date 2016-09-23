Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1676B0283
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 11:54:53 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id u18so39181901ita.2
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 08:54:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 27si9394881iot.201.2016.09.23.08.54.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 08:54:52 -0700 (PDT)
Date: Fri, 23 Sep 2016 17:53:51 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3 1/2] mm, proc: Fix region lost in /proc/self/smaps
Message-ID: <20160923155351.GA1584@redhat.com>
References: <1474636354-25573-1-git-send-email-robert.hu@intel.com> <20160923135635.GB28734@redhat.com> <20160923145301.GU4478@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160923145301.GU4478@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Robert Ho <robert.hu@intel.com>, pbonzini@redhat.com, akpm@linux-foundation.org, dan.j.williams@intel.com, dave.hansen@intel.com, guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On 09/23, Michal Hocko wrote:
>
> On Fri 23-09-16 15:56:36, Oleg Nesterov wrote:
> > 
> > I think we can simplify this patch. And imo make it better. How about
> 
> it is certainly less subtle because it doesn't report "sub-vmas".
> 
> > 	if (last_addr) {
> > 		vma = find_vma(mm, last_addr - 1);
> > 		if (vma && vma->vm_start <= last_addr)
> > 			vma = m_next_vma(priv, vma);
> > 		if (vma)
> > 			return vma;
> > 	}
> 
> we would still miss a VMA if the last one got shrunk/split

Not sure I understand what you mean... If the last one was split
we probably should not report the new vma. Nevermind, in any case
yes, sure, this can't "fix" other corner cases.

> So definitely an improvement but
> I guess we really want to document that only full reads provide a
> consistent (at some moment in time) output.

or all the threads were stopped. Agreed. And again, this applies to
any file in /proc.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
