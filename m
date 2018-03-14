Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4543D6B0005
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 17:46:10 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v8so1969485pgs.9
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 14:46:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m13si2449931pgd.641.2018.03.14.14.46.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 14:46:09 -0700 (PDT)
Date: Wed, 14 Mar 2018 14:46:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 8/285] fs//hugetlbfs/inode.c:142:22: note: in
 expansion of macro 'PGOFF_LOFFT_MAX'
Message-Id: <20180314144607.34f429990ccce6c4a244cbde@linux-foundation.org>
In-Reply-To: <0d54df0b-1e53-58a0-81ff-e496ae2f7cd8@oracle.com>
References: <201803141423.WZYJTFEz%fengguang.wu@intel.com>
	<0d54df0b-1e53-58a0-81ff-e496ae2f7cd8@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 14 Mar 2018 11:52:51 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> On 03/13/2018 11:15 PM, kbuild test robot wrote:
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   ead058c4ec49752a4e0323368f1d695385c66020
> > commit: af7abfba1161d2814301844fe11adac16910ea80 [8/285] hugetlbfs-check-for-pgoff-value-overflow-v3
> > config: sh-defconfig (attached as .config)
> > compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout af7abfba1161d2814301844fe11adac16910ea80
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=sh 
> > 
> > All warnings (new ones prefixed by >>):
> > 
> >    fs//hugetlbfs/inode.c: In function 'hugetlbfs_file_mmap':
> >>> fs//hugetlbfs/inode.c:118:36: warning: left shift count is negative [-Wshift-count-negative]
> >     #define PGOFF_LOFFT_MAX (PAGE_MASK << (BITS_PER_LONG - (2 * PAGE_SHIFT) - 1))
> >                                        ^
> 
> BITS_PER_LONG = 32 (32bit config)
> PAGE_SHIFT = 16 (64K pages)
> This results in the negative shift value.
> 
> I had proposed another (not so pretty way) to create the mask.
> 
> #define PGOFF_LOFFT_MAX \
> 	(((1UL << (PAGE_SHIFT + 1)) - 1) <<  (BITS_PER_LONG - (PAGE_SHIFT + 1)))
> 
> This works for the above config, and should work for any.
> 
> Andrew, how would you like me to update the patch?  I can send a new
> version but know you have also made some changes for VM_WARN.  Would
> you simply like a delta on top of the current patch?

This?

From: Andrew Morton <akpm@linux-foundation.org>
Subject: hugetlbfs-check-for-pgoff-value-overflow-v3-fix-fix

fix -ve left shift count on sh

Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Nic Losby <blurbdust@gmail.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/hugetlbfs/inode.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN mm/hugetlb.c~hugetlbfs-check-for-pgoff-value-overflow-v3-fix-fix mm/hugetlb.c
diff -puN fs/hugetlbfs/inode.c~hugetlbfs-check-for-pgoff-value-overflow-v3-fix-fix fs/hugetlbfs/inode.c
--- a/fs/hugetlbfs/inode.c~hugetlbfs-check-for-pgoff-value-overflow-v3-fix-fix
+++ a/fs/hugetlbfs/inode.c
@@ -115,7 +115,8 @@ static void huge_pagevec_release(struct
  * value.  The extra bit (- 1 in the shift value) is to take the sign
  * bit into account.
  */
-#define PGOFF_LOFFT_MAX (PAGE_MASK << (BITS_PER_LONG - (2 * PAGE_SHIFT) - 1))
+#define PGOFF_LOFFT_MAX \
+	(((1UL << (PAGE_SHIFT + 1)) - 1) <<  (BITS_PER_LONG - (PAGE_SHIFT + 1)))
 
 static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 {
_
