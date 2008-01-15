Received: by hs-out-2122.google.com with SMTP id 23so40224hsn.6
        for <linux-mm@kvack.org>; Tue, 15 Jan 2008 15:39:56 -0800 (PST)
Message-ID: <cfd9edbf0801151539g72ca9777h7ac43a31aadc730e@mail.gmail.com>
Date: Wed, 16 Jan 2008 00:39:55 +0100
From: "=?ISO-8859-1?Q?Daniel_Sp=E5ng?=" <daniel.spang@gmail.com>
Subject: Re: [RFC][PATCH 4/5] memory_pressure_notify() caller
In-Reply-To: <20080115175925.215471e1@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20080115092828.116F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080115100124.117B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <cfd9edbf0801151455j48669850s7ea4fe589dbb9710@mail.gmail.com>
	 <20080115175925.215471e1@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 1/15/08, Rik van Riel <riel@redhat.com> wrote:
>
> On Tue, 15 Jan 2008 23:55:17 +0100
> "Daniel Spang" <daniel.spang@gmail.com> wrote:
>
> > The notification fires after only ~100 MB allocated, i.e., when page
> > reclaim is beginning to nag from page cache. Isn't this a bit early?
> > Repeating the test with swap enabled results in a notification after
> > ~600 MB allocated, which is more reasonable and just before the system
> > starts to swap.
>
> Your issue may have more to do with the fact that the
> highmem zone is 128MB in size and some balancing issues
> between __alloc_pages and try_to_free_pages.

I don't think so. I ran the test again without highmem and noticed the
same behaviour:

$ cat /proc/meminfo
MemTotal:       895876 kB
MemFree:        111292 kB
Buffers:           924 kB
Cached:         768664 kB
SwapCached:          0 kB
Active:           9196 kB
Inactive:       767480 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       895876 kB
LowFree:        111292 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:              32 kB
Writeback:           0 kB
AnonPages:        7108 kB
Mapped:           1224 kB
Slab:             4288 kB
SReclaimable:     1316 kB
SUnreclaim:       2972 kB
PageTables:        448 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:    447936 kB
Committed_AS:    19676 kB
VmallocTotal:   122872 kB
VmallocUsed:       904 kB
VmallocChunk:   121864 kB

Start to allocate memory, 10 MB every second, exit on notification
which happened after 110 MB.

$ cat /proc/meminfo #after
MemTotal:       895876 kB
MemFree:        116748 kB
Buffers:           904 kB
Cached:         762944 kB
SwapCached:          0 kB
Active:          12864 kB
Inactive:       758064 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       895876 kB
LowFree:        116748 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:               4 kB
Writeback:           0 kB
AnonPages:        7108 kB
Mapped:           1224 kB
Slab:             4284 kB
SReclaimable:     1316 kB
SUnreclaim:       2968 kB
PageTables:        448 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:    447936 kB
Committed_AS:    19676 kB
VmallocTotal:   122872 kB
VmallocUsed:       904 kB
VmallocChunk:   121864 kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
