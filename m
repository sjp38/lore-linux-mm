Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 854E06B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 14:53:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c85so3217678pfb.12
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 11:53:55 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 91-v6si3873802plf.78.2018.04.19.11.53.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 11:53:54 -0700 (PDT)
Subject: Re: BUG: Bad page map in process python2 pte:10000000000
 pmd:17e8be067
References: <20180419054047.xxiljmzaf2u7odc6@wfg-t540p.sh.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <17463682-dc08-358d-8b44-02821352604c@intel.com>
Date: Thu, 19 Apr 2018 11:53:51 -0700
MIME-Version: 1.0
In-Reply-To: <20180419054047.xxiljmzaf2u7odc6@wfg-t540p.sh.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Huang Ying <ying.huang@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, lkp@01.org

On 04/18/2018 10:40 PM, Fengguang Wu wrote:
> [  716.494065] PASS concurrent_autogo_5ghz_ht40 4.803608 2018-03-23 09:57:21.586794
> [  716.494069]
> [  716.496923] passed all 1 test case(s)
> [  716.496926]
> [  716.511702] swap_info_get: Bad swap file entry 04000000
> [  716.512731] BUG: Bad page map in process python2  pte:100_0000_0000 pmd:17e8be067
> [  716.513844] addr:00000000860ba23b vm_flags:00000070 anon_vma:          (null) mapping:000000004c76fece index:1e2
> [  716.515160] file:libpcre.so.3.13.3 fault:filemap_fault mmap:generic_file_mmap readpage:simple_readpage
> [  716.516418] CPU: 2 PID: 8907 Comm: python2 Not tainted 4.16.0-rc5 #1
> [  716.517533] Hardware name:  /DH67GD, BIOS BLH6710H.86A.0132.2011.1007.1505 10/07/2011

Did you say that you have a few more examples of this?

I would be really interested if it's always python or always the same
shared library, or always file-backed memory, always the same bit,
etc...  From the vm_flags, I'd guess that this is the "rw-p" part of the
file mapping.

The bit that gets set is really weird.  It's bit 40.  I could definitely
see scenarios where we might set the dirty bit, or even NX for that
matter, or some *bit* that we mess with in software.  It's not even
close to the boundary where it could represent a swapoffset=1 or swapfile=1.

It's also unlikely to be _PAGE_PSE having gone missing from the PMD
since it's in the middle of a file-backed mapping and the PMD is
obviously pointing to a 4k page.

If I had to put money on it, I'd guess it's a hardware bit flip, or less
likely, a rogue software bit flip.  But, more examples will hopefully
shed some more light.
