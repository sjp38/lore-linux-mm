Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 41A796B0253
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 12:55:22 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 1so106741qtn.16
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 09:55:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r15si620096qtk.70.2017.11.02.09.55.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 09:55:19 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA2GrTbU045263
	for <linux-mm@kvack.org>; Thu, 2 Nov 2017 12:54:16 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2e03dc741t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Nov 2017 12:54:15 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 2 Nov 2017 16:54:13 -0000
Date: Thu, 2 Nov 2017 17:54:08 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH 0/3] lsmem/chmem: add memory zone awareness
In-Reply-To: <20171018114009.7b4iax6536un5bnr@ws.net.home>
References: <20170927174446.20459-1-gerald.schaefer@de.ibm.com>
	<20171018114009.7b4iax6536un5bnr@ws.net.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20171102175408.18d4eafc@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Karel Zak <kzak@redhat.com>
Cc: util-linux@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andre Wild <wild@linux.vnet.ibm.com>

On Wed, 18 Oct 2017 13:40:09 +0200
Karel Zak <kzak@redhat.com> wrote:

> On Wed, Sep 27, 2017 at 07:44:43PM +0200, Gerald Schaefer wrote:
> >  bash-completion/chmem                  |   1 +
> >  bash-completion/lsmem                  |   2 +-
> >  sys-utils/chmem.8                      |  19 +++++
> >  sys-utils/chmem.c                      | 136 +++++++++++++++++++++++++++++++--
> >  sys-utils/lsmem.1                      |   4 +-
> >  sys-utils/lsmem.c                      |  98 +++++++++++++++++++++++-
> >  tests/expected/lsmem/lsmem-s390-zvm-6g |  21 +++++
> >  tests/expected/lsmem/lsmem-x86_64-16g  |  39 ++++++++++
> >  tests/ts/lsmem/lsmem                   |   1 +
> >  9 files changed, 309 insertions(+), 12 deletions(-)  
> 
> Merged to my "next" branch (in master we have still feature-freeze).
> 
> I have also added a note about the way how lsmem merges blocks to
> create the RANGE column. It seems important, because the number of
> ranges is affected by ZONES (or REMOVABLE). See:
> 
>   https://github.com/karelzak/util-linux/commit/ffe5267c91018ca8cac8bedc14b695478c11a5dd
> 
> Maybe it's possible to explain it in a better way... (send patch;-)
> 
> The another possibility is to *always use* zones and removable
> attributes to create the ranges (merge blocks) independently on the
> output columns (e.g. -o ZONES). So, the result will be always the same
> number of ranges with the same <start>-<end>. 
> 
> Now (see the first range):
> 
> $ lsmem 
> RANGE                                  SIZE  STATE REMOVABLE  BLOCK
> 0x0000000000000000-0x0000000047ffffff  1.1G online        no    0-8
> 0x0000000048000000-0x0000000057ffffff  256M online       yes   9-10
> 0x0000000058000000-0x000000005fffffff  128M online        no     11
> 0x0000000060000000-0x0000000067ffffff  128M online       yes     12
> 0x0000000068000000-0x0000000087ffffff  512M online        no  13-16
> 0x0000000088000000-0x000000008fffffff  128M online       yes     17
> 0x0000000090000000-0x00000000afffffff  512M online        no  18-21
> 0x00000000b0000000-0x00000000bfffffff  256M online       yes  22-23
> 0x0000000100000000-0x000000042fffffff 12.8G online        no 32-133
> 0x0000000430000000-0x0000000437ffffff  128M online       yes    134
> 0x0000000438000000-0x000000043fffffff  128M online        no    135
> 
> lsmem -o+ZONES
> RANGE                                  SIZE  STATE REMOVABLE  BLOCK  ZONES
> 0x0000000000000000-0x0000000007ffffff  128M online        no      0   None
> 0x0000000008000000-0x0000000047ffffff    1G online        no    1-8  DMA32
> 0x0000000048000000-0x0000000057ffffff  256M online       yes   9-10  DMA32
> 0x0000000058000000-0x000000005fffffff  128M online        no     11  DMA32
> 0x0000000060000000-0x0000000067ffffff  128M online       yes     12  DMA32
> 0x0000000068000000-0x0000000087ffffff  512M online        no  13-16  DMA32
> 0x0000000088000000-0x000000008fffffff  128M online       yes     17  DMA32
> 0x0000000090000000-0x00000000afffffff  512M online        no  18-21  DMA32
> 0x00000000b0000000-0x00000000bfffffff  256M online       yes  22-23  DMA32
> 0x0000000100000000-0x000000042fffffff 12.8G online        no 32-133 Normal
> 0x0000000430000000-0x0000000437ffffff  128M online       yes    134 Normal
> 0x0000000438000000-0x000000043fffffff  128M online        no    135   None
> 
> lsmem -oRANGE,SIZE
> RANGE                                 SIZE
> 0x0000000000000000-0x00000000bfffffff   3G
> 0x0000000100000000-0x000000043fffffff  13G
> 
> 
> I didn't test it, but the question is how usable is 
> 0x0000000000000000-<end> as option for chmem.
> 
> It's also seems difficult to use it in scripts if you want to output only
> a RANGE, for example
> 
>     FOO=$(lsmem -oRANGE -n --summary=never | head -1)
>     
> but the range is affected by missing columns.
> 
> Comments?

Sorry for the late answer. I'm not sure if I understand the problem, it
"works as designed" that the range merging is done based on the output
columns, but I see that it was not really described as such. So I do
like the note that you added with the above mentioned commit.

However, regarding the --split option, I think it may be confusing at
least for human users, if an "lsmem -oRANGE" will now print more than
one range, even if this is now based on a "fixed" set of default columns
that are used for merging (but "subject to change" according to the man
page).

Now the user will not see the columns that are used for merging if he
says "lsmem -oRANGE", as opposed to the previous behavior where only the
visible output columns were used for merge decision (and for "lsmem
-oRANGE" that would simply be one big range because there are no other
columns that may differ).

I also do not really see the benefit for script usage, at least if we
define it as "expected behavior" to have the ranges merged based on the
output columns. Maybe I am missing something, but I think the --split
option does not really solve any problem, but rather introduces
potential for future confusion. I would rather only have the behavior
documented in the man pages, as you did in the above mentioned commit
(and which was then removed with the --split patch).

Regards,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
