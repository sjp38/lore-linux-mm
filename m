Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 046BD6B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:23:25 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id a45so1787273wra.14
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 03:23:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g63si1583622edd.382.2017.11.29.03.23.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 03:23:23 -0800 (PST)
Date: Wed, 29 Nov 2017 12:23:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 2/2] mm, hugetlb: do not rely on overcommit limit
 during migration
Message-ID: <20171129112322.ix3b4byfx2a3aktd@dhcp22.suse.cz>
References: <20171128101907.jtjthykeuefxu7gl@dhcp22.suse.cz>
 <20171128141211.11117-1-mhocko@kernel.org>
 <20171128141211.11117-3-mhocko@kernel.org>
 <20171129092234.eluli2gl7gotj35x@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129092234.eluli2gl7gotj35x@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 29-11-17 10:22:34, Michal Hocko wrote:
> What about this on top. I haven't tested this yet though.

OK, it seem to work:
root@test1:~# echo 1 > /proc/sys/vm/nr_hugepages
root@test1:~# echo 1 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_overcommit_hugepages

root@test1:~# grep . /sys/devices/system/node/node*/hugepages/hugepages-2048kB/*
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/free_hugepages:0
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages:0
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/surplus_hugepages:0
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/free_hugepages:1
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages:1
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/surplus_hugepages:0

# mmap 2 huge pages

root@test1:~# grep . /sys/devices/system/node/node*/hugepages/hugepages-2048kB/*
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/free_hugepages:0
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages:0
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/surplus_hugepages:0
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/free_hugepages:0
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages:2
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/surplus_hugepages:1

root@test1:~# migratepages $(pidof map_hugetlb) 1 0

/sys/devices/system/node/node0/hugepages/hugepages-2048kB/free_hugepages:0
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages:2
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/surplus_hugepages:1
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/free_hugepages:0
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages:0
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/surplus_hugepages:0

and exit the mmap

root@test1:~# grep . /sys/devices/system/node/node*/hugepages/hugepages-2048kB/*
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/free_hugepages:1
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages:1
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/surplus_hugepages:0
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/free_hugepages:0
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages:0
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/surplus_hugepages:0
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
