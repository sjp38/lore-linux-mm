Date: Mon, 21 Oct 2002 17:31:33 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: ZONE_NORMAL exhaustion (dcache slab)
Message-ID: <326730000.1035246693@flay>
In-Reply-To: <3DB4855F.D5DA002E@digeo.com>
References: <309670000.1035236015@flay> <Pine.LNX.4.44L.0210212028100.22993-100000@imladris.surriel.com> <3DB4855F.D5DA002E@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> On Mon, 21 Oct 2002, Martin J. Bligh wrote:
>> 
>> > > Blockdevices only use ZONE_NORMAL for their pagecache.  That cat will
>> > > selectively put pressure on the normal zone (and DMA zone, of course).
>> > 
>> > Ah, I recall that now. That's fundamentally screwed.
>> 
>> It's not too bad since the data can be reclaimed easily.
>> 
>> The problem in your case is that the dentry and inode cache
>> didn't get reclaimed. Maybe there is a leak so they can't get
>> reclaimed at all or maybe they just don't get reclaimed fast
>> enough.

OK, well "find / | xargs ls -l" results in:

dentry_cache      1125216 1125216    160 46884 46884    1 :  248  124

repeating it gives

dentry_cache      969475 1140960    160 47538 47540    1 :  248  124

Which is only a third of what I eventually ended up with over the weekend,
so presumably that means you're correct and there is a leak.

Hmmm .... but why did it shrink ... I didn't expect mem pressure just
doing a find ....

MemTotal:     16077728 kB
MemFree:      15070304 kB
MemShared:           0 kB
Buffers:         92400 kB
Cached:         266052 kB
SwapCached:          0 kB
Active:         351896 kB
Inactive:         9080 kB
HighTotal:    15335424 kB
HighFree:     15066160 kB
LowTotal:       742304 kB
LowFree:          4144 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:           32624 kB
Writeback:           0 kB
Mapped:           4956 kB
Slab:           630216 kB
Reserved:       570464 kB
Committed_AS:     6476 kB
PageTables:        236 kB
ReverseMaps:      3562

Pretty much all in slab ...

ext2_inode_cache  921200 938547    416 104283 104283    1 :  120   60
dentry_cache      1068133 1131096    160 47129 47129    1 :  248  124

So it looks as though it's actually ext2_inode cache that's first against the wall.
For comparison, over the weekend I ended up with:

ext2_inode_cache  554556 554598    416 61622 61622    1 :  120   60
dentry_cache      2791320 2791320    160 116305 116305    1 :  248  124

did a cat of /dev/sda2 > /dev/null ..... after that:

larry:~# egrep '(dentry|inode)' /proc/slabinfo
isofs_inode_cache      0      0    320    0    0    1 :  120   60
ext2_inode_cache  667345 809181    416 89909 89909    1 :  120   60
shmem_inode_cache      3      9    416    1    1    1 :  120   60
sock_inode_cache      16     22    352    2    2    1 :  120   60
proc_inode_cache      12     12    320    1    1    1 :  120   60
inode_cache          385    396    320   33   33    1 :  120   60
dentry_cache      1068289 1131096    160 47129 47129    1 :  248  124

larry:~# cat /proc/meminfo
MemTotal:     16077728 kB
MemFree:      15068684 kB
MemShared:           0 kB
Buffers:        165552 kB
Cached:         266052 kB
SwapCached:          0 kB
Active:         266620 kB
Inactive:       167524 kB
HighTotal:    15335424 kB
HighFree:     15066160 kB
LowTotal:       742304 kB
LowFree:          2524 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:               8 kB
Writeback:           0 kB
Mapped:           4956 kB
Slab:           558684 kB
Reserved:       570464 kB
Committed_AS:     6476 kB
PageTables:        236 kB
ReverseMaps:      3563

So it doesn't seem to shrink under mem pressure, but I can't reproduce 
the OOM at the moment either ;-(

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
