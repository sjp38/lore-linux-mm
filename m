Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A94C96B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 09:02:08 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l13-v6so16018509qth.8
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 06:02:08 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j4-v6si404373qte.29.2018.07.16.06.02.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 06:02:07 -0700 (PDT)
Date: Mon, 16 Jul 2018 21:02:02 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Bug report about KASLR and ZONE_MOVABLE
Message-ID: <20180716130202.GB1724@MiWiFi-R3L-srv>
References: <20180711094244.GA2019@localhost.localdomain>
 <20180711104158.GE2070@MiWiFi-R3L-srv>
 <20180711104944.GG1969@MiWiFi-R3L-srv>
 <20180711124008.GF2070@MiWiFi-R3L-srv>
 <72721138-ba6a-32c9-3489-f2060f40a4c9@cn.fujitsu.com>
 <20180712060115.GD6742@localhost.localdomain>
 <20180712123228.GK32648@dhcp22.suse.cz>
 <20180712235240.GH2070@MiWiFi-R3L-srv>
 <20180716113845.GM17280@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180716113845.GM17280@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chao Fan <fanc.fnst@cn.fujitsu.com>, Dou Liyang <douly.fnst@cn.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, yasu.isimatu@gmail.com, keescook@chromium.org, indou.takao@jp.fujitsu.com, caoj.fnst@cn.fujitsu.com, vbabka@suse.cz, mgorman@techsingularity.net

On 07/16/18 at 01:38pm, Michal Hocko wrote:
> On Fri 13-07-18 07:52:40, Baoquan He wrote:
> > Hi Michal,
> > 
> > On 07/12/18 at 02:32pm, Michal Hocko wrote:
> [...]
> > > I am not able to find the beginning of the email thread right now. Could
> > > you summarize what is the actual problem please?
> > 
> > The bug is found on x86 now. 
> > 
> > When added "kernelcore=" or "movablecore=" into kernel command line,
> > kernel memory is spread evenly among nodes. However, this is right when
> > KASLR is not enabled, then kernel will be at 16M of place in x86 arch.
> > If KASLR enabled, it could be put any place from 16M to 64T randomly.
> >  
> > Consider a scenario, we have 10 nodes, and each node has 20G memory, and
> > we specify "kernelcore=50%", means each node will take 10G for
> > kernelcore, 10G for movable area. But this doesn't take kernel position
> > into consideration. E.g if kernel is put at 15G of 2nd node, namely
> > node1. Then we think on node1 there's 10G for kernelcore, 10G for
> > movable, in fact there's only 5G available for movable, just after
> > kernel.
> 
> OK, I guess I see that part. But who is going to use movablecore along
> with KASLR enabled? I mean do we really have to support those two
> obscure command line parameters for KASLR?

Not very sure whether we have to support both of those to work with
KASLR. Maybe it's time to make clear of it now.

For 'kernelcore=mirror', we have solved the conflict to make it work well
with KASLR. For 'movable_node' conflict with KASLR, Chao is posting
patches to fix it. As for 'kernelcore=' and 'movablecore=', 

1) solve the conflict between them with KASLR in
   find_zone_movable_pfns_for_nodes();
2) disable KASLR when 'kernelcore=' | 'movablecore=' is set;
3) disable 'kernelcore=' | 'movablecore=' when KASLR is enabled;
4) add note in doc to notice people to not add them at the same time;

2) and 3) may need be fixed in arch/x86 code. As long as come to an
agreement, any one is fine to me.
> 
> In fact I would be much more concerned about memory hotplug and
> pre-defined movable nodes. Does the current KASLR code work in that
> case?

As said above, kernelcore=mirror works well with KASLR now. Making
'movable_node' work with KASLR is in progress.

Thanks
Baoquan
