Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 402C96B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 03:56:55 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m203so5131381wma.2
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 00:56:55 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id hc8si24431961wjc.214.2016.11.22.00.56.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 00:56:53 -0800 (PST)
Received: by mail-wm0-f47.google.com with SMTP id t79so13052100wmt.0
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 00:56:53 -0800 (PST)
Subject: Re: Softlockup during memory allocation
References: <e3177ea6-a921-dac9-f4f3-952c14e2c4df@kyup.com>
 <a73f4917-48ac-bf1e-04d9-64fb937abfc6@kyup.com>
 <CAJFSNy5_z_FA4DTPAtqBdOU+LmnfvdeVBtDhHuperv1MVU-9VA@mail.gmail.com>
 <20161121053154.GA29816@dhcp22.suse.cz>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <ab42c7a5-49e2-4e46-be60-e0a56704a11d@kyup.com>
Date: Tue, 22 Nov 2016 10:56:51 +0200
MIME-Version: 1.0
In-Reply-To: <20161121053154.GA29816@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>



On 11/21/2016 07:31 AM, Michal Hocko wrote:
> Hi,
> I am sorry for a late response, but I was offline until this weekend. I
> will try to get to this email ASAP but it might take some time.

No worries. I did some further digging up and here is what I got, which
I believe is rather strange:

struct scan_control {
  nr_to_reclaim = 32,
  gfp_mask = 37880010,
  order = 0,
  nodemask = 0x0,
  target_mem_cgroup = 0xffff8823990d1400,
  priority = 7,
  may_writepage = 1,
  may_unmap = 1,
  may_swap = 0,
  may_thrash = 1,
  hibernation_mode = 0,
  compaction_ready = 0,
  nr_scanned = 0,
  nr_reclaimed = 0
}

Parsing: 37880010
#define ___GFP_HIGHMEM		0x02
#define ___GFP_MOVABLE		0x08
#define ___GFP_IO		0x40
#define ___GFP_FS		0x80
#define ___GFP_HARDWALL		0x20000
#define ___GFP_DIRECT_RECLAIM	0x400000
#define ___GFP_KSWAPD_RECLAIM	0x2000000

And initial_priority is 12 (DEF_PRIORITY). Given that nr_scanned is 0
and priority is 7 this means we've gone 5 times through the do {} while
in do_try_to_free_pages. Also total_scanned seems to be 0.  Here is the
zone which was being reclaimed :

http://sprunge.us/hQBi

So what's strange is that the softlockup occurred but then the code
proceeded (as evident from the subsequent stack traces), yet inspecting
the reclaim progress it seems rather sad (no progress at all)


> 
> On Mon 14-11-16 00:02:57, Nikolay Borisov wrote:
>> Ping on that Michal, in case you've missed it. This seems like a
>> genuine miss of a cond_resched. Can you at least confirm my analysis
>> or is it complete bollocks?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
