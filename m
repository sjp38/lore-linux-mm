Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 292F16B013D
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 04:19:59 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c13so1589614eek.26
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 01:19:57 -0700 (PDT)
Message-ID: <515FDAAA.2060301@suse.cz>
Date: Sat, 06 Apr 2013 10:19:54 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
References: <20130402142717.GH32241@suse.de> <20130402150651.GB31577@thunk.org> <20130402151436.GC31577@thunk.org> <20130403101925.GA7341@suse.de> <515F4DA3.2000000@suse.cz> <20130405231635.GA6521@thunk.org> <515FCEEC.9070504@suse.cz> <515FD0C6.5050001@suse.cz>
In-Reply-To: <515FD0C6.5050001@suse.cz>
Content-Type: multipart/mixed;
 boundary="------------060909010405030807060106"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mgorman@suse.de>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

This is a multi-part message in MIME format.
--------------060909010405030807060106
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 04/06/2013 09:37 AM, Jiri Slaby wrote:
> On 04/06/2013 09:29 AM, Jiri Slaby wrote:
>> On 04/06/2013 01:16 AM, Theodore Ts'o wrote:
>>> On Sat, Apr 06, 2013 at 12:18:11AM +0200, Jiri Slaby wrote:
>>>> Ok, so now I'm runnning 3.9.0-rc5-next-20130404, it's not that bad, but
>>>> it still sucks. Updating a kernel in a VM still results in "Your system
>>>> is too SLOW to play this!" by mplayer and frame dropping.
>>>
>>> What was the first kernel where you didn't have the problem?  Were you
>>> using the 3.8 kernel earlier, and did you see the interactivity
>>> problems there?
>>
>> I'm not sure, as I am using -next like for ever. But sure, there was a
>> kernel which didn't ahve this problem.
>>
>>> What else was running in on your desktop at the same time?
>>
>> Nothing, just VM (kernel update from console) and mplayer2 on the host.
>> This is more-or-less reproducible with these two.
> 
> Ok,
>   dd if=/dev/zero of=xxx
> is enough instead of "kernel update".
> 
> Writeback mount doesn't help.
> 
>>> How was
>>> the file system mounted,
>>
>> Both are actually a single device /dev/sda5:
>> /dev/sda5 on /win type ext4 (rw,noatime,data=ordered)
>>
>> Should I try writeback?
>>
>>> and can you send me the output of dumpe2fs -h
>>> /dev/XXX?
>>
>> dumpe2fs 1.42.7 (21-Jan-2013)
>> Filesystem volume name:   <none>
>> Last mounted on:          /win
>> Filesystem UUID:          cd4bf4d2-bc32-4777-a437-ee24c4ee5f1b
>> Filesystem magic number:  0xEF53
>> Filesystem revision #:    1 (dynamic)
>> Filesystem features:      has_journal ext_attr resize_inode dir_index
>> filetype needs_recovery extent flex_bg sparse_super large_file huge_file
>> uninit_bg dir_nlink extra_isize
>> Filesystem flags:         signed_directory_hash
>> Default mount options:    user_xattr acl
>> Filesystem state:         clean
>> Errors behavior:          Continue
>> Filesystem OS type:       Linux
>> Inode count:              30507008
>> Block count:              122012416
>> Reserved block count:     0
>> Free blocks:              72021328
>> Free inodes:              30474619
>> First block:              0
>> Block size:               4096
>> Fragment size:            4096
>> Reserved GDT blocks:      994
>> Blocks per group:         32768
>> Fragments per group:      32768
>> Inodes per group:         8192
>> Inode blocks per group:   512
>> RAID stride:              32747
>> Flex block group size:    16
>> Filesystem created:       Fri Sep  7 20:44:21 2012
>> Last mount time:          Thu Apr  4 12:22:01 2013
>> Last write time:          Thu Apr  4 12:22:01 2013
>> Mount count:              256
>> Maximum mount count:      -1
>> Last checked:             Sat Sep  8 21:13:28 2012
>> Check interval:           0 (<none>)
>> Lifetime writes:          1011 GB
>> Reserved blocks uid:      0 (user root)
>> Reserved blocks gid:      0 (group root)
>> First inode:              11
>> Inode size:               256
>> Required extra isize:     28
>> Desired extra isize:      28
>> Journal inode:            8
>> Default directory hash:   half_md4
>> Directory Hash Seed:      b6ad3f8b-72ce-49d6-92cb-abccd7dbe98e
>> Journal backup:           inode blocks
>> Journal features:         journal_incompat_revoke
>> Journal size:             128M
>> Journal length:           32768
>> Journal sequence:         0x00054dc7
>> Journal start:            8193
>>
>>> Oh, and what options were you using to when you kicked off
>>> the VM?
>>
>> qemu-kvm -k en-us -smp 2 -m 1200 -soundhw hda -usb -usbdevice tablet
>> -net user -net nic,model=e1000 -serial pty -balloon virtio -hda x.img
>>
>>> The other thing that would be useful was to enable the jbd2_run_stats
>>> tracepoint and to send the output of the trace log when you notice the
>>> interactivity problems.
>>
>> Ok, I will try.

Inline here, as well as attached:
# tracer: nop
#
# entries-in-buffer/entries-written: 46/46   #P:2
#
#                              _-----=> irqs-off
#                             / _----=> need-resched
#                            | / _---=> hardirq/softirq
#                            || / _--=> preempt-depth
#                            ||| /     delay
#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#              | |       |   ||||       |         |
     jbd2/sda5-8-10969 [000] ....   387.054319: jbd2_run_stats: dev
259,655360 tid 348892 wait 0 request_delay 0 running 5728 locked 0
flushing 0 logging 28 handle_count 10 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   392.594132: jbd2_run_stats: dev
259,655360 tid 348893 wait 0 request_delay 0 running 5300 locked 0
flushing 0 logging 64 handle_count 75944 blocks 1 blocks_logged 2
      jbd2/md2-8-959   [000] ....   396.249990: jbd2_run_stats: dev 9,2
tid 382990 wait 0 request_delay 0 running 5500 locked 0 flushing 0
logging 220 handle_count 3 blocks 1 blocks_logged 2
      jbd2/md1-8-1826  [000] ....   397.205670: jbd2_run_stats: dev 9,1
tid 1081270 wait 0 request_delay 0 running 5760 locked 0 flushing 0
logging 200 handle_count 2 blocks 0 blocks_logged 0
     jbd2/sda5-8-10969 [000] ....   397.563660: jbd2_run_stats: dev
259,655360 tid 348894 wait 0 request_delay 0 running 5000 locked 0
flushing 0 logging 32 handle_count 89397 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   403.679552: jbd2_run_stats: dev
259,655360 tid 348895 wait 0 request_delay 0 running 5000 locked 1040
flushing 0 logging 112 handle_count 148224 blocks 1 blocks_logged 2
      jbd2/md1-8-1826  [000] ....   407.981693: jbd2_run_stats: dev 9,1
tid 1081271 wait 0 request_delay 0 running 5064 locked 0 flushing 0
logging 152 handle_count 198 blocks 20 blocks_logged 21
      jbd2/md2-8-959   [000] ....   408.111339: jbd2_run_stats: dev 9,2
tid 382991 wait 0 request_delay 0 running 5156 locked 2268 flushing 0
logging 124 handle_count 5 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   408.823650: jbd2_run_stats: dev
259,655360 tid 348896 wait 0 request_delay 0 running 5156 locked 0
flushing 0 logging 100 handle_count 63257 blocks 1 blocks_logged 2
      jbd2/md1-8-1826  [000] ....   411.385104: jbd2_run_stats: dev 9,1
tid 1081272 wait 0 request_delay 0 running 3236 locked 0 flushing 0
logging 116 handle_count 42 blocks 7 blocks_logged 8
      jbd2/md1-8-1826  [000] ....   412.590289: jbd2_run_stats: dev 9,1
tid 1081273 wait 0 request_delay 0 running 124 locked 0 flushing 0
logging 740 handle_count 7 blocks 5 blocks_logged 6
      jbd2/md2-8-959   [000] ....   413.087300: jbd2_run_stats: dev 9,2
tid 382992 wait 0 request_delay 0 running 5012 locked 0 flushing 0
logging 92 handle_count 12 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   414.047500: jbd2_run_stats: dev
259,655360 tid 348897 wait 0 request_delay 0 running 5004 locked 32
flushing 0 logging 292 handle_count 104485 blocks 4 blocks_logged 5
      jbd2/md2-8-959   [000] ....   418.301823: jbd2_run_stats: dev 9,2
tid 382993 wait 0 request_delay 0 running 5024 locked 0 flushing 0
logging 284 handle_count 4 blocks 0 blocks_logged 0
      jbd2/md1-8-1826  [001] ....   418.384624: jbd2_run_stats: dev 9,1
tid 1081274 wait 0 request_delay 0 running 5416 locked 0 flushing 0
logging 384 handle_count 393 blocks 14 blocks_logged 15
     jbd2/sda5-8-10969 [000] ....   418.599524: jbd2_run_stats: dev
259,655360 tid 348898 wait 0 request_delay 0 running 4736 locked 0
flushing 0 logging 112 handle_count 43360 blocks 17 blocks_logged 18
      jbd2/md1-8-1826  [001] ....   418.711491: jbd2_run_stats: dev 9,1
tid 1081275 wait 0 request_delay 0 running 40 locked 0 flushing 0
logging 48 handle_count 4 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   422.444437: jbd2_run_stats: dev
259,655360 tid 348899 wait 0 request_delay 0 running 3684 locked 0
flushing 0 logging 144 handle_count 62564 blocks 22 blocks_logged 23
     jbd2/sda5-8-10969 [000] ....   427.903435: jbd2_run_stats: dev
259,655360 tid 348900 wait 0 request_delay 0 running 5332 locked 0
flushing 0 logging 128 handle_count 118362 blocks 19 blocks_logged 20
     jbd2/sda5-8-10969 [000] ....   431.981049: jbd2_run_stats: dev
259,655360 tid 348901 wait 0 request_delay 0 running 3976 locked 0
flushing 0 logging 100 handle_count 88833 blocks 13 blocks_logged 14
      jbd2/md1-8-1826  [001] ....   437.291566: jbd2_run_stats: dev 9,1
tid 1081276 wait 0 request_delay 0 running 244 locked 0 flushing 0
logging 380 handle_count 5 blocks 6 blocks_logged 7
     jbd2/sda5-8-10969 [000] ....   437.342205: jbd2_run_stats: dev
259,655360 tid 348902 wait 0 request_delay 0 running 5016 locked 0
flushing 0 logging 344 handle_count 134290 blocks 13 blocks_logged 14
     jbd2/sda5-8-10969 [000] ....   441.879748: jbd2_run_stats: dev
259,655360 tid 348903 wait 0 request_delay 0 running 3624 locked 0
flushing 0 logging 76 handle_count 81013 blocks 13 blocks_logged 14
     jbd2/sda5-8-10969 [000] ....   447.059645: jbd2_run_stats: dev
259,655360 tid 348904 wait 0 request_delay 0 running 5048 locked 0
flushing 0 logging 128 handle_count 127735 blocks 13 blocks_logged 14
     jbd2/sda5-8-10969 [001] ....   447.667205: jbd2_run_stats: dev
259,655360 tid 348905 wait 0 request_delay 0 running 580 locked 0
flushing 0 logging 156 handle_count 131 blocks 4 blocks_logged 5
     jbd2/sda5-8-10969 [001] ....   453.156101: jbd2_run_stats: dev
259,655360 tid 348906 wait 0 request_delay 0 running 5308 locked 0
flushing 0 logging 184 handle_count 109134 blocks 16 blocks_logged 17
     jbd2/sda5-8-10969 [001] ....   456.546335: jbd2_run_stats: dev
259,655360 tid 348907 wait 0 request_delay 0 running 3248 locked 0
flushing 0 logging 228 handle_count 66315 blocks 10 blocks_logged 11
      jbd2/md2-8-959   [001] ....   458.812838: jbd2_run_stats: dev 9,2
tid 382994 wait 0 request_delay 0 running 5052 locked 92 flushing 0
logging 232 handle_count 8 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   462.113411: jbd2_run_stats: dev
259,655360 tid 348908 wait 0 request_delay 0 running 5292 locked 4
flushing 0 logging 268 handle_count 139470 blocks 14 blocks_logged 15
      jbd2/md2-8-959   [001] ....   463.012109: jbd2_run_stats: dev 9,2
tid 382995 wait 0 request_delay 0 running 4380 locked 0 flushing 0
logging 52 handle_count 3 blocks 0 blocks_logged 0
     jbd2/sda5-8-10969 [000] ....   463.012121: jbd2_run_stats: dev
259,655360 tid 348909 wait 0 request_delay 0 running 1116 locked 0
flushing 0 logging 52 handle_count 5 blocks 4 blocks_logged 5
     jbd2/sda5-8-10969 [001] ....   468.229949: jbd2_run_stats: dev
259,655360 tid 348910 wait 0 request_delay 0 running 5012 locked 0
flushing 0 logging 204 handle_count 134170 blocks 18 blocks_logged 19
      jbd2/md2-8-959   [000] ....   473.230180: jbd2_run_stats: dev 9,2
tid 382996 wait 0 request_delay 0 running 5116 locked 0 flushing 0
logging 268 handle_count 3 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   473.422616: jbd2_run_stats: dev
259,655360 tid 348911 wait 0 request_delay 0 running 5292 locked 0
flushing 0 logging 108 handle_count 84844 blocks 15 blocks_logged 16
      jbd2/md1-8-1826  [000] ....   477.503164: jbd2_run_stats: dev 9,1
tid 1081277 wait 0 request_delay 0 running 5580 locked 0 flushing 0
logging 852 handle_count 124 blocks 4 blocks_logged 5
     jbd2/sda5-8-10969 [000] ....   479.048020: jbd2_run_stats: dev
259,655360 tid 348912 wait 0 request_delay 0 running 5000 locked 212
flushing 0 logging 416 handle_count 139926 blocks 17 blocks_logged 18
      jbd2/md1-8-1826  [000] ....   482.570545: jbd2_run_stats: dev 9,1
tid 1081278 wait 0 request_delay 0 running 5316 locked 0 flushing 0
logging 604 handle_count 11 blocks 0 blocks_logged 0
     jbd2/sda5-8-10969 [001] ....   484.456879: jbd2_run_stats: dev
259,655360 tid 348913 wait 0 request_delay 0 running 5284 locked 0
flushing 0 logging 544 handle_count 40620 blocks 11 blocks_logged 12
     jbd2/sda5-8-10969 [001] ....   486.014655: jbd2_run_stats: dev
259,655360 tid 348914 wait 0 request_delay 0 running 1540 locked 108
flushing 0 logging 456 handle_count 55965 blocks 4 blocks_logged 5
     jbd2/sda5-8-10969 [001] ....   491.082420: jbd2_run_stats: dev
259,655360 tid 348915 wait 0 request_delay 0 running 5160 locked 0
flushing 0 logging 368 handle_count 33509 blocks 12 blocks_logged 13
      jbd2/md1-8-1826  [000] ....   494.688094: jbd2_run_stats: dev 9,1
tid 1081279 wait 0 request_delay 0 running 5828 locked 0 flushing 0
logging 716 handle_count 2 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   497.548126: jbd2_run_stats: dev
259,655360 tid 348916 wait 0 request_delay 0 running 5020 locked 36
flushing 0 logging 1780 handle_count 1481 blocks 13 blocks_logged 14
      jbd2/md2-8-959   [000] ....   500.647267: jbd2_run_stats: dev 9,2
tid 382997 wait 0 request_delay 0 running 5272 locked 244 flushing 0
logging 432 handle_count 5 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   501.134535: jbd2_run_stats: dev
259,655360 tid 348917 wait 0 request_delay 0 running 5040 locked 0
flushing 0 logging 328 handle_count 755 blocks 4 blocks_logged 5
      jbd2/md1-8-1826  [001] ....   502.020846: jbd2_run_stats: dev 9,1
tid 1081280 wait 0 request_delay 0 running 5896 locked 0 flushing 0
logging 52 handle_count 20 blocks 5 blocks_logged 6
      jbd2/md2-8-959   [000] ....   505.989307: jbd2_run_stats: dev 9,2
tid 382998 wait 0 request_delay 0 running 5756 locked 0 flushing 0
logging 20 handle_count 8 blocks 1 blocks_logged 2

thanks,
-- 
js
suse labs

--------------060909010405030807060106
Content-Type: text/plain; charset=UTF-8;
 name="trace"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="trace"

# tracer: nop
#
# entries-in-buffer/entries-written: 46/46   #P:2
#
#                              _-----=> irqs-off
#                             / _----=> need-resched
#                            | / _---=> hardirq/softirq
#                            || / _--=> preempt-depth
#                            ||| /     delay
#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#              | |       |   ||||       |         |
     jbd2/sda5-8-10969 [000] ....   387.054319: jbd2_run_stats: dev 259,655360 tid 348892 wait 0 request_delay 0 running 5728 locked 0 flushing 0 logging 28 handle_count 10 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   392.594132: jbd2_run_stats: dev 259,655360 tid 348893 wait 0 request_delay 0 running 5300 locked 0 flushing 0 logging 64 handle_count 75944 blocks 1 blocks_logged 2
      jbd2/md2-8-959   [000] ....   396.249990: jbd2_run_stats: dev 9,2 tid 382990 wait 0 request_delay 0 running 5500 locked 0 flushing 0 logging 220 handle_count 3 blocks 1 blocks_logged 2
      jbd2/md1-8-1826  [000] ....   397.205670: jbd2_run_stats: dev 9,1 tid 1081270 wait 0 request_delay 0 running 5760 locked 0 flushing 0 logging 200 handle_count 2 blocks 0 blocks_logged 0
     jbd2/sda5-8-10969 [000] ....   397.563660: jbd2_run_stats: dev 259,655360 tid 348894 wait 0 request_delay 0 running 5000 locked 0 flushing 0 logging 32 handle_count 89397 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   403.679552: jbd2_run_stats: dev 259,655360 tid 348895 wait 0 request_delay 0 running 5000 locked 1040 flushing 0 logging 112 handle_count 148224 blocks 1 blocks_logged 2
      jbd2/md1-8-1826  [000] ....   407.981693: jbd2_run_stats: dev 9,1 tid 1081271 wait 0 request_delay 0 running 5064 locked 0 flushing 0 logging 152 handle_count 198 blocks 20 blocks_logged 21
      jbd2/md2-8-959   [000] ....   408.111339: jbd2_run_stats: dev 9,2 tid 382991 wait 0 request_delay 0 running 5156 locked 2268 flushing 0 logging 124 handle_count 5 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   408.823650: jbd2_run_stats: dev 259,655360 tid 348896 wait 0 request_delay 0 running 5156 locked 0 flushing 0 logging 100 handle_count 63257 blocks 1 blocks_logged 2
      jbd2/md1-8-1826  [000] ....   411.385104: jbd2_run_stats: dev 9,1 tid 1081272 wait 0 request_delay 0 running 3236 locked 0 flushing 0 logging 116 handle_count 42 blocks 7 blocks_logged 8
      jbd2/md1-8-1826  [000] ....   412.590289: jbd2_run_stats: dev 9,1 tid 1081273 wait 0 request_delay 0 running 124 locked 0 flushing 0 logging 740 handle_count 7 blocks 5 blocks_logged 6
      jbd2/md2-8-959   [000] ....   413.087300: jbd2_run_stats: dev 9,2 tid 382992 wait 0 request_delay 0 running 5012 locked 0 flushing 0 logging 92 handle_count 12 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   414.047500: jbd2_run_stats: dev 259,655360 tid 348897 wait 0 request_delay 0 running 5004 locked 32 flushing 0 logging 292 handle_count 104485 blocks 4 blocks_logged 5
      jbd2/md2-8-959   [000] ....   418.301823: jbd2_run_stats: dev 9,2 tid 382993 wait 0 request_delay 0 running 5024 locked 0 flushing 0 logging 284 handle_count 4 blocks 0 blocks_logged 0
      jbd2/md1-8-1826  [001] ....   418.384624: jbd2_run_stats: dev 9,1 tid 1081274 wait 0 request_delay 0 running 5416 locked 0 flushing 0 logging 384 handle_count 393 blocks 14 blocks_logged 15
     jbd2/sda5-8-10969 [000] ....   418.599524: jbd2_run_stats: dev 259,655360 tid 348898 wait 0 request_delay 0 running 4736 locked 0 flushing 0 logging 112 handle_count 43360 blocks 17 blocks_logged 18
      jbd2/md1-8-1826  [001] ....   418.711491: jbd2_run_stats: dev 9,1 tid 1081275 wait 0 request_delay 0 running 40 locked 0 flushing 0 logging 48 handle_count 4 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   422.444437: jbd2_run_stats: dev 259,655360 tid 348899 wait 0 request_delay 0 running 3684 locked 0 flushing 0 logging 144 handle_count 62564 blocks 22 blocks_logged 23
     jbd2/sda5-8-10969 [000] ....   427.903435: jbd2_run_stats: dev 259,655360 tid 348900 wait 0 request_delay 0 running 5332 locked 0 flushing 0 logging 128 handle_count 118362 blocks 19 blocks_logged 20
     jbd2/sda5-8-10969 [000] ....   431.981049: jbd2_run_stats: dev 259,655360 tid 348901 wait 0 request_delay 0 running 3976 locked 0 flushing 0 logging 100 handle_count 88833 blocks 13 blocks_logged 14
      jbd2/md1-8-1826  [001] ....   437.291566: jbd2_run_stats: dev 9,1 tid 1081276 wait 0 request_delay 0 running 244 locked 0 flushing 0 logging 380 handle_count 5 blocks 6 blocks_logged 7
     jbd2/sda5-8-10969 [000] ....   437.342205: jbd2_run_stats: dev 259,655360 tid 348902 wait 0 request_delay 0 running 5016 locked 0 flushing 0 logging 344 handle_count 134290 blocks 13 blocks_logged 14
     jbd2/sda5-8-10969 [000] ....   441.879748: jbd2_run_stats: dev 259,655360 tid 348903 wait 0 request_delay 0 running 3624 locked 0 flushing 0 logging 76 handle_count 81013 blocks 13 blocks_logged 14
     jbd2/sda5-8-10969 [000] ....   447.059645: jbd2_run_stats: dev 259,655360 tid 348904 wait 0 request_delay 0 running 5048 locked 0 flushing 0 logging 128 handle_count 127735 blocks 13 blocks_logged 14
     jbd2/sda5-8-10969 [001] ....   447.667205: jbd2_run_stats: dev 259,655360 tid 348905 wait 0 request_delay 0 running 580 locked 0 flushing 0 logging 156 handle_count 131 blocks 4 blocks_logged 5
     jbd2/sda5-8-10969 [001] ....   453.156101: jbd2_run_stats: dev 259,655360 tid 348906 wait 0 request_delay 0 running 5308 locked 0 flushing 0 logging 184 handle_count 109134 blocks 16 blocks_logged 17
     jbd2/sda5-8-10969 [001] ....   456.546335: jbd2_run_stats: dev 259,655360 tid 348907 wait 0 request_delay 0 running 3248 locked 0 flushing 0 logging 228 handle_count 66315 blocks 10 blocks_logged 11
      jbd2/md2-8-959   [001] ....   458.812838: jbd2_run_stats: dev 9,2 tid 382994 wait 0 request_delay 0 running 5052 locked 92 flushing 0 logging 232 handle_count 8 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   462.113411: jbd2_run_stats: dev 259,655360 tid 348908 wait 0 request_delay 0 running 5292 locked 4 flushing 0 logging 268 handle_count 139470 blocks 14 blocks_logged 15
      jbd2/md2-8-959   [001] ....   463.012109: jbd2_run_stats: dev 9,2 tid 382995 wait 0 request_delay 0 running 4380 locked 0 flushing 0 logging 52 handle_count 3 blocks 0 blocks_logged 0
     jbd2/sda5-8-10969 [000] ....   463.012121: jbd2_run_stats: dev 259,655360 tid 348909 wait 0 request_delay 0 running 1116 locked 0 flushing 0 logging 52 handle_count 5 blocks 4 blocks_logged 5
     jbd2/sda5-8-10969 [001] ....   468.229949: jbd2_run_stats: dev 259,655360 tid 348910 wait 0 request_delay 0 running 5012 locked 0 flushing 0 logging 204 handle_count 134170 blocks 18 blocks_logged 19
      jbd2/md2-8-959   [000] ....   473.230180: jbd2_run_stats: dev 9,2 tid 382996 wait 0 request_delay 0 running 5116 locked 0 flushing 0 logging 268 handle_count 3 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   473.422616: jbd2_run_stats: dev 259,655360 tid 348911 wait 0 request_delay 0 running 5292 locked 0 flushing 0 logging 108 handle_count 84844 blocks 15 blocks_logged 16
      jbd2/md1-8-1826  [000] ....   477.503164: jbd2_run_stats: dev 9,1 tid 1081277 wait 0 request_delay 0 running 5580 locked 0 flushing 0 logging 852 handle_count 124 blocks 4 blocks_logged 5
     jbd2/sda5-8-10969 [000] ....   479.048020: jbd2_run_stats: dev 259,655360 tid 348912 wait 0 request_delay 0 running 5000 locked 212 flushing 0 logging 416 handle_count 139926 blocks 17 blocks_logged 18
      jbd2/md1-8-1826  [000] ....   482.570545: jbd2_run_stats: dev 9,1 tid 1081278 wait 0 request_delay 0 running 5316 locked 0 flushing 0 logging 604 handle_count 11 blocks 0 blocks_logged 0
     jbd2/sda5-8-10969 [001] ....   484.456879: jbd2_run_stats: dev 259,655360 tid 348913 wait 0 request_delay 0 running 5284 locked 0 flushing 0 logging 544 handle_count 40620 blocks 11 blocks_logged 12
     jbd2/sda5-8-10969 [001] ....   486.014655: jbd2_run_stats: dev 259,655360 tid 348914 wait 0 request_delay 0 running 1540 locked 108 flushing 0 logging 456 handle_count 55965 blocks 4 blocks_logged 5
     jbd2/sda5-8-10969 [001] ....   491.082420: jbd2_run_stats: dev 259,655360 tid 348915 wait 0 request_delay 0 running 5160 locked 0 flushing 0 logging 368 handle_count 33509 blocks 12 blocks_logged 13
      jbd2/md1-8-1826  [000] ....   494.688094: jbd2_run_stats: dev 9,1 tid 1081279 wait 0 request_delay 0 running 5828 locked 0 flushing 0 logging 716 handle_count 2 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   497.548126: jbd2_run_stats: dev 259,655360 tid 348916 wait 0 request_delay 0 running 5020 locked 36 flushing 0 logging 1780 handle_count 1481 blocks 13 blocks_logged 14
      jbd2/md2-8-959   [000] ....   500.647267: jbd2_run_stats: dev 9,2 tid 382997 wait 0 request_delay 0 running 5272 locked 244 flushing 0 logging 432 handle_count 5 blocks 1 blocks_logged 2
     jbd2/sda5-8-10969 [000] ....   501.134535: jbd2_run_stats: dev 259,655360 tid 348917 wait 0 request_delay 0 running 5040 locked 0 flushing 0 logging 328 handle_count 755 blocks 4 blocks_logged 5
      jbd2/md1-8-1826  [001] ....   502.020846: jbd2_run_stats: dev 9,1 tid 1081280 wait 0 request_delay 0 running 5896 locked 0 flushing 0 logging 52 handle_count 20 blocks 5 blocks_logged 6
      jbd2/md2-8-959   [000] ....   505.989307: jbd2_run_stats: dev 9,2 tid 382998 wait 0 request_delay 0 running 5756 locked 0 flushing 0 logging 20 handle_count 8 blocks 1 blocks_logged 2

--------------060909010405030807060106--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
