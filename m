Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4086E6B006C
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 13:55:46 -0500 (EST)
Date: Tue, 22 Nov 2011 19:55:40 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: slub: Lockout validation scans during freeing of object
Message-ID: <20111122185540.GA1627@x4.trippels.de>
References: <alpine.DEB.2.00.1111221033350.28197@router.home>
 <alpine.DEB.2.00.1111221040300.28197@router.home>
 <alpine.DEB.2.00.1111221052130.28197@router.home>
 <1321982484.18002.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <alpine.DEB.2.00.1111221139240.28197@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1111221139240.28197@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Christian Kujau <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On 2011.11.22 at 11:40 -0600, Christoph Lameter wrote:
> On Tue, 22 Nov 2011, Eric Dumazet wrote:
> 
> > This seems better, but I still have some warnings :
> 
> Trying to reproduce with a kernel configured to do preempt. This is
> actually quite interesting since its always off by 1.

BTW there are some obvious overflows in the "slabinfo -l" output on my machine:

Name                   Objects Objsize    Space Slabs/Part/Cpu  O/S O %Fr %Ef Flg
:t-0000024                 680      24    16.3K          0/0/4  170 0   0  99 *
:t-0000032                 768      32    24.5K          0/0/6  128 0   0 100 *
:t-0000040                1632      40    65.5K         13/0/3  102 0   0  99 *
:t-0000048                4533      48   241.6K 18446744073709551583/9/92   85 0  15  90 *
:t-0000064                3392      64   217.0K        30/0/23   64 0   0 100 *
:t-0000072                4368      72   319.4K         73/0/5   56 0   0  98 *
:t-0000112                 720     112    81.9K         0/0/20   36 0   0  98 *
:t-0000128                1684     128   233.4K 18446744073709551607/7/66   32 0  12  92 *
:t-0000136                 120     136    16.3K          0/0/4   30 0   0  99 *
:t-0000144                8036     144     1.1M        283/0/4   28 0   0  98 *
:t-0000192                4452     192   872.4K       165/0/48   21 0   0  97 *
:t-0000216                  90     216    20.4K          1/0/4   18 0   0  94 *
:t-0000256                 539     256   147.4K 18446744073709551609/3/43   16 0   8  93 *
:t-0000320                2425     320   794.6K         93/0/4   25 1   0  97 *A
:t-0000400                  60     400    24.5K          0/0/3   20 1   0  97 *
:t-0000512                 640     512   327.6K        23/0/17   16 1   0 100 *
:t-0000704                 483     704   344.0K         0/0/21   23 2   0  98 *A
:t-0001024                 373    1024   475.1K       15/10/14   16 2  34  80 *
:t-0002048                 288    2048   589.8K         10/0/8   16 3   0 100 *
:t-0004096                 119    4096   524.2K         4/3/12    8 3  18  92 *
Acpi-State                 204      80    16.3K          0/0/4   51 0   0  99 
anon_vma                  3528      64   258.0K         9/0/54   56 0   0  87 
bdev_cache                  84     728    65.5K          0/0/4   21 2   0  93 Aa
blkdev_queue                38    1664    65.5K          0/0/2   19 3   0  96 
blkdev_requests            161     344    57.3K          0/0/7   23 1   0  96 
buffer_head               1014     104   106.4K         5/0/21   39 0   0  99 a
cfq_queue                  102     232    24.5K          1/0/5   17 0   0  96 
dentry                   15897     192     3.1M       723/0/34   21 0   0  98 a
idr_layer_cache            390     544   212.9K          8/0/5   30 2   0  99 
inode_cache               6448     512     3.4M        199/0/9   31 2   0  96 a
ip_fib_trie                219      56    12.2K          0/0/3   73 0   0  99 
kmalloc-16                3072      16    49.1K          7/0/5  256 0   0 100 
kmalloc-8                 4608       8    36.8K          4/0/5  512 0   0 100 
kmalloc-8192                20    8192   163.8K          1/0/4    4 3   0 100 
kmalloc-96                 840      96    81.9K         7/0/13   42 0   0  98 
kmem_cache                  21     192     4.0K          0/0/1   21 0   0  98 *A
kmem_cache_node            192      64    12.2K          0/0/3   64 0   0 100 *A
mm_struct                  171     832   147.4K          0/0/9   19 2   0  96 A
mqueue_inode_cache          19     800    16.3K          0/0/1   19 2   0  92 A
nf_conntrack_ffffffff8199e380       60     264    16.3K          0/0/2   30 1   0  96 
proc_inode_cache           420     576   245.7K         2/0/13   28 2   0  98 a
radix_tree_node           3472     560     2.0M        120/0/4   28 2   0  95 a
RAW                         42     712    32.7K          0/0/2   21 2   0  91 A
shmem_inode_cache         1036     576   606.2K        21/0/16   28 2   0  98 
sighand_cache              210    2088   458.7K         3/0/11   15 3   0  95 A
signal_cache               268     920   360.4K 18446744073709551614/7/24   17 2  31  68 A
sigqueue                   125     160    20.4K          0/0/5   25 0   0  97 
skbuff_fclone_cache         72     420    32.7K          0/0/4   18 1   0  92 A
sock_inode_cache           196     560   114.6K          0/0/7   28 2   0  95 Aa
task_struct                215    1504   557.0K          9/9/8   21 3  52  58 
TCP                         21    1504    32.7K          0/0/1   21 3   0  96 A
UDP                         63     736    49.1K          0/0/3   21 2   0  94 A
vm_area_struct            3278     168   602.1K       89/33/58   24 0  22  91 
xfs_btree_cur               76     208    16.3K          0/0/4   19 0   0  96 
xfs_buf_item               108     224    24.5K          0/0/6   18 0   0  98 
xfs_da_state                64     488    32.7K          0/0/4   16 1   0  95 
xfs_inode                 7055     896     6.7M        411/0/4   17 2   0  92 Aa
xfs_log_ticket              80     200    16.3K          0/0/4   20 0   0  97 
xfs_trans                  116     280    32.7K          0/0/4   29 1   0  99 


-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
