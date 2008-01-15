Received: by nz-out-0506.google.com with SMTP id i11so32214nzh.26
        for <linux-mm@kvack.org>; Tue, 15 Jan 2008 14:55:18 -0800 (PST)
Message-ID: <cfd9edbf0801151455j48669850s7ea4fe589dbb9710@mail.gmail.com>
Date: Tue, 15 Jan 2008 23:55:17 +0100
From: "=?ISO-8859-1?Q?Daniel_Sp=E5ng?=" <daniel.spang@gmail.com>
Subject: Re: [RFC][PATCH 4/5] memory_pressure_notify() caller
In-Reply-To: <20080115100124.117B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080115092828.116F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080115100124.117B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

On 1/15/08, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> the notification point to happen whenever the VM moves an
> anonymous page to the inactive list - this is a pretty good indication
> that there are unused anonymous pages present which will be very likely
> swapped out soon.

> +                               /* deal with the case where there is no
> +                                * swap but an anonymous page would be
> +                                * moved to the inactive list.
> +                                */
> +                               if (!total_swap_pages && reclaim_mapped &&
> +                                   PageAnon(page))
> +                                       inactivated_anon = 1;

As you know I have had some concerns regarding a too early
notification in a swapless system.

I did a test with a populated page cache in a swapless system:

$ cat /bigfile > /dev/null # populate page cache
$ cat /proc/meminfo
MemTotal:      1037040 kB
MemFree:        113976 kB
Buffers:          1068 kB
Cached:         907552 kB
SwapCached:          0 kB
Active:          11116 kB
Inactive:       903968 kB
HighTotal:      130992 kB
HighFree:          252 kB
LowTotal:       906048 kB
LowFree:        113724 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:              36 kB
Writeback:           0 kB
AnonPages:        6484 kB
Mapped:           1216 kB
Slab:             4024 kB
SReclaimable:      864 kB
SUnreclaim:       3160 kB
PageTables:        444 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:    518520 kB
Committed_AS:    18816 kB
VmallocTotal:   114680 kB
VmallocUsed:       904 kB
VmallocChunk:   113672 kB

Start to allocate memory, 10 MB every second, exit on notification.

$ cat /proc/meminfo # just after notification
MemTotal:      1037040 kB
MemFree:        123468 kB
Buffers:           876 kB
Cached:         897976 kB
SwapCached:          0 kB
Active:          12984 kB
Inactive:       892332 kB
HighTotal:      130992 kB
HighFree:         1064 kB
LowTotal:       906048 kB
LowFree:        122404 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:               0 kB
Writeback:           0 kB
AnonPages:        6484 kB
Mapped:           1220 kB
Slab:             4012 kB
SReclaimable:      864 kB
SUnreclaim:       3148 kB
PageTables:        448 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:    518520 kB
Committed_AS:    18816 kB
VmallocTotal:   114680 kB
VmallocUsed:       904 kB
VmallocChunk:   113672 kB

The notification fires after only ~100 MB allocated, i.e., when page
reclaim is beginning to nag from page cache. Isn't this a bit early?
Repeating the test with swap enabled results in a notification after
~600 MB allocated, which is more reasonable and just before the system
starts to swap.

Cheers,
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
