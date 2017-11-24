Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 388506B0069
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 04:43:44 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 4so21299785pge.8
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 01:43:44 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id n127si17791483pga.104.2017.11.24.01.43.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 01:43:43 -0800 (PST)
Received: from epcas5p3.samsung.com (unknown [182.195.41.41])
	by mailout1.samsung.com (KnoxPortal) with ESMTP id 20171124094340epoutp01bc06d1f14e6ea94632fcce40bd4774a7~5-Fui3O5A2286922869epoutp01d
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 09:43:40 +0000 (GMT)
Mime-Version: 1.0
Subject: Re: [PATCH 1/1] stackdepot: interface to check entries and size of
 stackdepot.
Reply-To: maninder1.s@samsung.com
From: Maninder Singh <maninder1.s@samsung.com>
In-Reply-To: <20171123162835.6prpgrz3qkdexx56@dhcp22.suse.cz>
Message-ID: <20171124094108epcms5p396558828a365a876d61205b0fdb501fd@epcms5p3>
Date: Fri, 24 Nov 2017 09:41:08 +0000
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
References: <20171123162835.6prpgrz3qkdexx56@dhcp22.suse.cz>
	<1511347661-38083-1-git-send-email-maninder1.s@samsung.com>
	<CGME20171122105142epcas5p173b7205da12e1fc72e16ec74c49db665@epcms5p3>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "jkosina@suse.cz" <jkosina@suse.cz>, "pombredanne@nexb.com" <pombredanne@nexb.com>, "jpoimboe@redhat.com" <jpoimboe@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "guptap@codeaurora.org" <guptap@codeaurora.org>, "vinmenon@codeaurora.org" <vinmenon@codeaurora.org>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, PANKAJ MISHRA <pankaj.m@samsung.com>, Lalit Mohan Tripathi <lalit.mohan@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vaneet Narang <v.narang@samsung.com>

Hi Michal,
  
> On Wed 22-11-17 16:17:41, Maninder Singh wrote:
> > This patch provides interface to check all the stack enteries
> > saved in stackdepot so far as well as memory consumed by stackdepot.
> > 
> > 1) Take current depot_index and offset to calculate end address for one
> >         iteration of (/sys/kernel/debug/depot_stack/depot_entries).
> > 
> > 2) Fill end marker in every slab to point its end, and then use it while
> >         traversing all the slabs of stackdepot.
> > 
> > "debugfs code inspired from page_onwer's way of printing BT"
> > 
> > checked on ARM and x86_64.
> > $cat /sys/kernel/debug/depot_stack/depot_size
> > Memory consumed by Stackdepot:208 KB
> > 
> > $ cat /sys/kernel/debug/depot_stack/depot_entries
> > stack count 1 backtrace
> >  init_page_owner+0x1e/0x210
> >  start_kernel+0x310/0x3cd
> >  secondary_startup_64+0xa5/0xb0
> >  0xffffffffffffffff
>  
> Why do we need this? Who is goging to use this information and what for?
> I haven't looked at the code but just the diffstat looks like this
> should better have a _very_ good justification to be considered for
> merging. To be honest with you I have hard time imagine how this can be
> useful other than debugging stack depot...

This interface can be used for multiple reasons as:

1) For debugging stackdepot for sure.
2) For checking all the unique allocation paths in system.
3) To check if any invalid stack is coming which is increasing 
stackdepot memory.
(https://lkml.org/lkml/2017/10/11/353)

Althoutgh this needs to be taken care in ARM as replied by maintainer, but with help
of this interface it was quite easy to check and we added workaround for saving memory.

4) At some point of time to check current memory consumed by stackdepot.
5) To check number of entries in stackdepot to decide stackdepot hash size for different systems. 
   For fewer entries hash table size can be reduced from 4MB. 

Thanks
Maninder Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
