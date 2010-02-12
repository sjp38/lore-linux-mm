Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 28B616B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 02:42:19 -0500 (EST)
Message-ID: <4B7504D2.1040903@nortel.com>
Date: Fri, 12 Feb 2010 01:35:46 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: Re: tracking memory usage/leak in "inactive" field in /proc/meminfo?
References: <4B71927D.6030607@nortel.com>	 <20100210093140.12D9.A69D9226@jp.fujitsu.com>	 <4B72E74C.9040001@nortel.com>	 <28c262361002101645g3fd08cc7t6a72d27b1f94db62@mail.gmail.com>	 <4B74524D.8080804@nortel.com> <28c262361002111838q7db763feh851a9bea4fdd9096@mail.gmail.com>
In-Reply-To: <28c262361002111838q7db763feh851a9bea4fdd9096@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 02/11/2010 08:38 PM, Minchan Kim wrote:
> On Fri, Feb 12, 2010 at 3:54 AM, Chris Friesen <cfriesen@nortel.com> wrote:
>> That just makes the comparison even worse...it means that there is more
>> memory in active/inactive that isn't accounted for in any other category
>> in /proc/meminfo.
> 
> Hmm. It's very strange. It's impossible if your kernel and drivers is normal.
> Could you grep sources who increases NR_ACTIVE/INACTIVE?
> I doubt one of your driver does increase and miss decrease.

I instrumented the page cache to track all additions/subtractions of
pages to/from the LRU.  I also added some page flags to track pages
counting towards NR_FILE_PAGES and NR_ANON_PAGES.  I then periodically
scanned all of the pages on the LRU and if they weren't part of
NR_FILE_PAGES or NR_ANON_PAGES I dumped the call chain of the code that
added the page to the LRU.

After being up about 2.5 hrs, there were 4265 pages in the LRU that
weren't part of file or anon.  These broke down into two separate call
chains (there were actually three separate offsets within
compat_do_execve, but the rest was identical):


  backtrace:
    [<ffffffff8061c162>] kmemleak_alloc_page+0x1eb/0x380
    [<ffffffff80276ae8>] __pagevec_lru_add_active+0xb6/0x104
    [<ffffffff80276b85>] lru_cache_add_active+0x4f/0x53
    [<ffffffff8027d182>] do_wp_page+0x355/0x6f6
    [<ffffffff8027eef1>] handle_mm_fault+0x62b/0x77c
    [<ffffffff80632557>] do_page_fault+0x3c7/0xba0
    [<ffffffff8062fb79>] error_exit+0x0/0x51
    [<ffffffffffffffff>] 0xffffffffffffffff

and

  backtrace:
    [<ffffffff8061c162>] kmemleak_alloc_page+0x1eb/0x380
    [<ffffffff80276ae8>] __pagevec_lru_add_active+0xb6/0x104
    [<ffffffff80276b85>] lru_cache_add_active+0x4f/0x53
    [<ffffffff8027eddc>] handle_mm_fault+0x516/0x77c
    [<ffffffff8027f180>] get_user_pages+0x13e/0x462
    [<ffffffff802a2f65>] get_arg_page+0x6a/0xca
    [<ffffffff802a30bf>] copy_strings+0xfa/0x1d4
    [<ffffffff802a31c7>] copy_strings_kernel+0x2e/0x43
    [<ffffffff802d33fb>] compat_do_execve+0x1fa/0x2fd
    [<ffffffff8021e405>] sys32_execve+0x44/0x62
    [<ffffffff8021def5>] ia32_ptregs_common+0x25/0x50
    [<ffffffffffffffff>] 0xffffffffffffffff

I'll dig into them further, but do either of these look like known issues?

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
