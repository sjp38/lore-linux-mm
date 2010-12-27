Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 25E966B0087
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 16:52:44 -0500 (EST)
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Date: Tue, 28 Dec 2010 00:52:03 +0300
From: Vasiliy G Tolstov <v.tolstov@selfip.ru>
Subject: Re: [Xen-devel] Re: [PATCH 2/3] drivers/xen/balloon.c: Various
 balloon features and fixes
Reply-To: v.tolstov@selfip.ru
In-Reply-To: <20101227163918.GB7189@dumpdata.com>
References: <20101220134724.GC6749@router-fw-old.local.net-space.pl>
 <20101227150847.GA3728@dumpdata.com>
 <947c7677e042b3fd1ca22d775ca9aeb9@imap.selfip.ru>
 <20101227163918.GB7189@dumpdata.com>
Message-ID: <92e9dd494cc640c04fdac03fa6d10e8d@imap.selfip.ru>
Sender: owner-linux-mm@kvack.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: jeremy@goop.org, xen-devel@lists.xensource.com, haicheng.li@linux.intel.com, dan.magenheimer@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi.kleen@intel.com, akpm@linux-foundation.org, fengguang.wu@intel.com, Daniel Kiper <dkiper@net-space.pl>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Dec 2010 11:39:18 -0500, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> On Mon, Dec 27, 2010 at 07:27:56PM +0300, Vasiliy G Tolstov wrote:
>> On Mon, 27 Dec 2010 10:08:47 -0500, Konrad Rzeszutek Wilk
>> <konrad.wilk@oracle.com> wrote:
>> > On Mon, Dec 20, 2010 at 02:47:24PM +0100, Daniel Kiper wrote:
>> >> Features and fixes:
>> >>   - HVM mode is supported now,
>> >>   - migration from mod_timer() to schedule_delayed_work(),
>> >>   - removal of driver_pages (I do not have seen any
>> >>     references to it),
>> >>   - protect before CPU exhaust by event/x process during
>> >>     errors by adding some delays in scheduling next event,
>> >>   - some other minor fixes.
>>
>> I have apply this patch to bare 2.6.36.2 kernel from kernel.org. If
>> memory=maxmemory pv guest run's on migrating fine.
>> If on already running domU i have xm mem-max xxx 1024 (before that it
>> has 768) and do xm mem-set 1024 guest now have 1024 memory, but after
>> that it can't migrate to another host.
>>
>> Step to try to start guest with memory=512 and maxmemory=1024 it boot
>> fine, xm mem-set work's fine, but.. it can't migrate. Sorry but nothing
>> on screen , how can i help to debug this problem?
> 
> You can play with 'xenctx' to see where the guest is stuck. You can also
> look in the 'xm dmesg' to see if there is something odd. Lastly, if you
> mean by 'can't migrate to another host' as the command hangs stops, look
> at the error code (or in /var/log/xen files) and also look in the source
> code.
> 

xm dmesg and /var/log/xen/* provide nothing useful. can't migrate meand
- xm migrate --live start migration process, on destination node domain
constucted all memory copied and after that in xentop picture like this:
1) some second after migration xentop displays line like this:

test_domain -----r          2  109.8     262144    0.4    1048576      
1.7    14    1        0        0    2        0        0        0        
0          0    0

2) after that some second line changed to this:

test_domain ---c--          3  245.6     262144    0.4    1048576      
1.7    14    1        0        0    2        0        0        0        
0          0    0

3) after some milli seconds:

test_domain ---cp-          3    0.0     111460    0.2    1048576      
1.7    14    1        0        0    2        0        0        0        
0          0    0

4) after 2 or 3 seconds like this:

test_domain d--cp-          3    0.0          4    0.0    1048576      
1.7    14    1        0        0    2        0        0        0        
0          0    0

after step 4 domain is crushed. If i don't use Daniel's patch - this
not happening.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
