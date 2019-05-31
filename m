Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 354F6C46460
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 21:27:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF11822CD1
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 21:27:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AIcLhb/v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF11822CD1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79A9E6B0276; Fri, 31 May 2019 17:27:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74B896B0277; Fri, 31 May 2019 17:27:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 63A586B0278; Fri, 31 May 2019 17:27:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 465386B0276
	for <linux-mm@kvack.org>; Fri, 31 May 2019 17:27:24 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id v11so8652892iop.7
        for <linux-mm@kvack.org>; Fri, 31 May 2019 14:27:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=FdeTkmBVwuTsg9/OnbIAmaMsZgODf1ybKhTYqSHrOFU=;
        b=GOuEqxPVZS5myKkAl/TAl4xiWfpazUf1yAHoxrtFI2+iuK+86ar7mhm7xtY0l0rC3Y
         eYCbelzBnDxKS+DDxXB9Z8fcbl0mBVYMQHD8ZqPsj9jBhsX02cr/HIgdIAk6Y1BOoxq+
         PyEBOv9R+DWON+1vhNOAhu+pRzyUjTyoS2JHv9+yRAwGPikt9LW9y9dQtbclUunXKv7e
         Ccc0xFHpBPxQBL3jDR0hN8l9VBgAe2yYtBWvmARyBE/LUwTSIXehJ0cAenAHQAxrsiTH
         mRVoQwtAqb8XmHqyypuf6U3MmceULUMApM0BUSgWB2IraAFWPnizhFq+WAtmHRlmK03y
         5qGw==
X-Gm-Message-State: APjAAAXCThmaXs+zKwKiLInNF7adPVQ3drze4/31TIjftBbHsVnNZsdh
	6ZOwkCfZyjuwJELBOYH6cSy7SCea/r8c+byZ+KLibqT6gs97Jr31pud2zZDt7iMglpR5F6zc6Zn
	GtCfYtSAjynGDtTEMgExPoKVOiOhotIS9AI/8YeOU5+4Q3EmFjhfJUJslV+6CXM9ndQ==
X-Received: by 2002:a24:53c4:: with SMTP id n187mr9102226itb.167.1559338044014;
        Fri, 31 May 2019 14:27:24 -0700 (PDT)
X-Received: by 2002:a24:53c4:: with SMTP id n187mr9102184itb.167.1559338043121;
        Fri, 31 May 2019 14:27:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559338043; cv=none;
        d=google.com; s=arc-20160816;
        b=HIzqU6XHM+7p3kVUBz+X40Q88JfoqdgHwtcB+j8Ralbyt0QAsqKrv+F8GOsB1Qie2Z
         3ZeWpO3fCOFEk/4MliXIkrYjExadFX6muuFN/LtkIIR0+yI0rF3MaLBRzXUVvmiBtZW3
         /tVChn/WSLsvRGZKhpa2XVAjHWr1khPnk/Rto7CLoQBwJSTfD6LY3OxNS+ZMZL+DZczW
         YCgYUNZoT4GTqXLZEewURGQfxWeA6sEVhEGJAYh5jgcqurVfixN/eB6DNmg0QxdcXmXk
         iavzDO7BKQPSePyFwhApghtYu2VEju/xnDRiQIK9bKS3jYdecIRsT1NLMy4DxMz1I2PW
         82Ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=FdeTkmBVwuTsg9/OnbIAmaMsZgODf1ybKhTYqSHrOFU=;
        b=ra5LMJKNUMmRSbh0RzQ5rdv3UptYzN8dFhF9Og8swhADom5xDkWTyzhlQ5NTXbFnCC
         HnYd1FC5TSUI0lntr2EWShqexZK5eBkLMThqaW00PWyLBl4dYEES3LSm3AwFOmmNEbgZ
         8dixGMeMppoHWuD5Eartp6NT6GOtL25UyI6uO6mHKHFHd7+fNLVURvc3PelmSld6JJRl
         n9MFDeJODOFdNLmo3RyVrgETfwEjHk8dEBSrvFSUCnjcPvmvep0gTfW2RF03WypC68E3
         Y1hb9uzZI7+ACVpWxqMazRhAPuIOhLNb5VaDnDh3wGPhunyY42EtiB77tbr7EKWKgb66
         DEUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="AIcLhb/v";
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1sor4015501ioc.19.2019.05.31.14.27.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 14:27:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="AIcLhb/v";
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=FdeTkmBVwuTsg9/OnbIAmaMsZgODf1ybKhTYqSHrOFU=;
        b=AIcLhb/vlk+W1AXCq4+Bj+HBM5ms7RqXWnfxz18AeLzokwU+IOaBst0FSd5WGxtNkJ
         AkGYqZlFkgsL5piSnG+UjFpuN7oWbo7jzzkYE48Q/cwzLepPvhMVMASSddCAny/PUedQ
         jxqk9mDBvNk9yO5f6jYc2VFoOPYf9c7SEiYyYWwJuWwCnkRlWG+jsXHQPLeSGqU1n4u7
         8920IsL6NLrK651eNBFKq5P3PlSDScFtw5P/WYBMtTFg5Q1HhYXYGxwj3jd2nk8/c8BO
         FkglW/ibTxkjDPKj+kG7VN3Gjd0DrGP4t9nxzRnitMypRdDFg8Il8e2e3Bp/Ku4ERUJ0
         valw==
X-Google-Smtp-Source: APXvYqxh3yq9Mo93WxApHkDs9lJMaYoeZiDTUsl8QEzt/uqjj0Jb0nRYhNUqrHlD9QsSkP9pnQWM4TpJ91RPduiuzi0=
X-Received: by 2002:a6b:b790:: with SMTP id h138mr7854002iof.64.1559338042423;
 Fri, 31 May 2019 14:27:22 -0700 (PDT)
MIME-Version: 1.0
References: <09c5d10e9d6b4c258b22db23e7a17513@UUSALE1A.utcmail.com>
In-Reply-To: <09c5d10e9d6b4c258b22db23e7a17513@UUSALE1A.utcmail.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 31 May 2019 14:27:11 -0700
Message-ID: <CAKgT0UfoLDxL_8QkF_fuUK-2-6KGFr5y=2_nRZCNc_u+d+LCrg@mail.gmail.com>
Subject: Re: linux kernel page allocation failure and tuning of page cache
To: "Nagal, Amit UTC CCS" <Amit.Nagal@utc.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"CHAWLA, RITU UTC CCS" <RITU.CHAWLA@utc.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 8:07 AM Nagal, Amit UTC CCS <Amit.Nagal@utc.com> wr=
ote:
>
> Hi
>
> We are using Renesas RZ/A1 processor based custom target board . linux ke=
rnel version is 4.9.123.
>
> 1) the platform is low memory platform having memory 64MB.
>
> 2)  we are doing around 45MB TCP data transfer from PC to target using ne=
tcat utility .On Target , a process receives data over socket and writes th=
e data to flash disk .
>
> 3) At the start of data transfer , we explicitly clear linux kernel cache=
d memory by  calling echo 3 > /proc/sys/vm/drop_caches .
>
> 4) during TCP data transfer , we could see free -m showing "free" getting=
 dropped to almost 1MB and most of the memory appearing as "cached"
>
> # free -m
>                                             total         used   free    =
 shared   buffers   cached
> Mem:                                  57            56         1         =
        0            2           42
> -/+ buffers/cache:                          12        45
> Swap:                                   0              0           0
>
> 5) sometimes , we observed kernel memory getting exhausted as page alloca=
tion failure happens in kernel  with the backtrace is printed below :
> # [  775.947949] nc.traditional: page allocation failure: order:0, mode:0=
x2080020(GFP_ATOMIC)
> [  775.956362] CPU: 0 PID: 1288 Comm: nc.traditional Tainted: G          =
 O    4.9.123-pic6-g31a13de-dirty #19
> [  775.966085] Hardware name: Generic R7S72100 (Flattened Device Tree)
> [  775.972501] [<c0109829>] (unwind_backtrace) from [<c010796f>] (show_st=
ack+0xb/0xc)
> [  775.980118] [<c010796f>] (show_stack) from [<c0151de3>] (warn_alloc+0x=
89/0xba)
> [  775.987361] [<c0151de3>] (warn_alloc) from [<c0152043>] (__alloc_pages=
_nodemask+0x1eb/0x634)
> [  775.995790] [<c0152043>] (__alloc_pages_nodemask) from [<c0152523>] (_=
_alloc_page_frag+0x39/0xde)
> [  776.004685] [<c0152523>] (__alloc_page_frag) from [<c03190f1>] (__netd=
ev_alloc_skb+0x51/0xb0)
> [  776.013217] [<c03190f1>] (__netdev_alloc_skb) from [<c02c1b6f>] (sh_et=
h_poll+0xbf/0x3c0)
> [  776.021342] [<c02c1b6f>] (sh_eth_poll) from [<c031fd8f>] (net_rx_actio=
n+0x77/0x170)
> [  776.029051] [<c031fd8f>] (net_rx_action) from [<c011238f>] (__do_softi=
rq+0x107/0x160)
> [  776.036896] [<c011238f>] (__do_softirq) from [<c0112589>] (irq_exit+0x=
5d/0x80)
> [  776.044165] [<c0112589>] (irq_exit) from [<c012f4db>] (__handle_domain=
_irq+0x57/0x8c)
> [  776.052007] [<c012f4db>] (__handle_domain_irq) from [<c01012e1>] (gic_=
handle_irq+0x31/0x48)
> [  776.060362] [<c01012e1>] (gic_handle_irq) from [<c0108025>] (__irq_svc=
+0x65/0xac)
> [  776.067835] Exception stack(0xc1cafd70 to 0xc1cafdb8)
> [  776.072876] fd60:                                     0002751c c1dec6a=
0 0000000c 521c3be5
> [  776.081042] fd80: 56feb08e f64823a6 ffb35f7b feab513d f9cb0643 0000056=
c c1caff10 ffffe000
> [  776.089204] fda0: b1f49160 c1cafdc4 c180c677 c0234ace 200e0033 fffffff=
f
> [  776.095816] [<c0108025>] (__irq_svc) from [<c0234ace>] (__copy_to_user=
_std+0x7e/0x430)
> [  776.103796] [<c0234ace>] (__copy_to_user_std) from [<c0241715>] (copy_=
page_to_iter+0x105/0x250)
> [  776.112503] [<c0241715>] (copy_page_to_iter) from [<c0319aeb>] (skb_co=
py_datagram_iter+0xa3/0x108)
> [  776.121469] [<c0319aeb>] (skb_copy_datagram_iter) from [<c03443a7>] (t=
cp_recvmsg+0x3ab/0x5f4)
> [  776.130045] [<c03443a7>] (tcp_recvmsg) from [<c035e249>] (inet_recvmsg=
+0x21/0x2c)
> [  776.137576] [<c035e249>] (inet_recvmsg) from [<c031009f>] (sock_read_i=
ter+0x51/0x6e)
> [  776.145384] [<c031009f>] (sock_read_iter) from [<c017795d>] (__vfs_rea=
d+0x97/0xb0)
> [  776.152967] [<c017795d>] (__vfs_read) from [<c01781d9>] (vfs_read+0x51=
/0xb0)
> [  776.159983] [<c01781d9>] (vfs_read) from [<c0178aab>] (SyS_read+0x27/0=
x52)
> [  776.166837] [<c0178aab>] (SyS_read) from [<c0105261>] (ret_fast_syscal=
l+0x1/0x54)

So it looks like you are interrupting the process that is draining the
socket to service the interrupt that is filling it. I am curious what
your tcp_rmem value is. If this is occurring often then you will
likely build up a backlog of packets in the receive buffer for the
socket and that may be where all your memory is going.

> [  776.174308] Mem-Info:
> [  776.176650] active_anon:2037 inactive_anon:23 isolated_anon:0
> [  776.176650]  active_file:2636 inactive_file:7391 isolated_file:32
> [  776.176650]  unevictable:0 dirty:1366 writeback:1281 unstable:0
> [  776.176650]  slab_reclaimable:719 slab_unreclaimable:724
> [  776.176650]  mapped:1990 shmem:26 pagetables:159 bounce:0
> [  776.176650]  free:373 free_pcp:6 free_cma:0
> [  776.209062] Node 0 active_anon:8148kB inactive_anon:92kB active_file:1=
0544kB inactive_file:29564kB unevictable:0kB isolated(anon):0kB isolated(fi=
le):128kB mapped:7960kB dirty:5464kB writeback:5124kB shmem:104kB writeback=
_tmp:0kB unstable:0kB pages_scanned:0 all_unreclaimable? no
> [  776.233602] Normal free:1492kB min:964kB low:1204kB high:1444kB active=
_anon:8148kB inactive_anon:92kB active_file:10544kB inactive_file:29564kB u=
nevictable:0kB writepending:10588kB present:65536kB managed:59304kB mlocked=
:0kB slab_reclaimable:2876kB slab_unreclaimable:2896kB kernel_stack:1152kB =
pagetables:636kB bounce:0kB free_pcp:24kB local_pcp:24kB free_cma:0kB
> [  776.265406] lowmem_reserve[]: 0 0
> [  776.268761] Normal: 7*4kB (H) 5*8kB (H) 7*16kB (H) 5*32kB (H) 6*64kB (=
H) 2*128kB (H) 2*256kB (H) 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 1492kB
> 10071 total pagecache pages
> [  776.284124] 0 pages in swap cache
> [  776.287446] Swap cache stats: add 0, delete 0, find 0/0
> [  776.292645] Free swap  =3D 0kB
> [  776.295532] Total swap =3D 0kB
> [  776.298421] 16384 pages RAM
> [  776.301224] 0 pages HighMem/MovableOnly
> [  776.305052] 1558 pages reserved
>
> 6) we have certain questions as below :
> a) how the kernel memory got exhausted ? at the time of low memory condit=
ions in kernel , are the kernel page flusher threads , which should have wr=
itten dirty pages from page cache to flash disk , not executing at right ti=
me ? is the kernel page reclaim mechanism not executing at right time ?

I suspect the pages are likely stuck in a state of buffering. In the
case of sockets the packets will get queued up until either they can
be serviced or the maximum size of the receive buffer as been exceeded
and they are dropped.

> b) are there any parameters available within the linux memory subsystem w=
ith which the reclaim procedure can be monitored and  fine tuned ?

I don't think freeing up more memory will solve the issue. I really
think you probably should look at tuning the network settings. I
suspect the socket itself is likely the thing holding all of the
memory.

> c) can  some amount of free memory be reserved so that linux kernel does =
not caches it and kernel can use it for its other required page allocation =
( particularly gfp_atomic ) as needed above on behalf of netcat nc process =
? can some tuning be done in linux memory subsystem eg by using /proc/sys/v=
m/min_free_kbytes  to achieve this objective .

Within the kernel we already have some emergency reserved that get
dipped into if the PF_MEMALLOC flag is set. However that is usually
reserved for the cases where you are booting off of something like
iscsi or NVMe over TCP.

> d) can we be provided with further clues on how to debug this issue furth=
er for out of memory condition in kernel  ?

My advice would be look at tuning your TCP socket values in sysctl. I
suspect you are likely using a larger window then your system can
currently handle given the memory constraints and that what you are
seeing is that all the memory is being consumed by buffering for the
TCP socket.

