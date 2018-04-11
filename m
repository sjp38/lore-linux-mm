Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD2F6B0005
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 05:35:11 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id z39-v6so716866ota.11
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 02:35:11 -0700 (PDT)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id 32-v6si260321otr.343.2018.04.11.02.35.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Apr 2018 02:35:09 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [RFC] linux 3.4 BUG on lib/prio_tree.c:280!
Message-ID: <e0575035-54b2-c3a0-b34c-e9124c9bc756@huawei.com>
Date: Wed, 11 Apr 2018 17:33:31 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: zhongjiang <zhongjiang@huawei.com>, wu.wujiangtao@huawei.com, yanaijie@huawei.com, mgorman@techsingularity.net, jack@suse.cz, jlayton@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Yisheng Xie <xieyisheng1@huawei.com>

Hi all,

We meet a problem with linux 3.4, which trigger BUG on lib/prio_tree.c:280!

kernel BUG at /usr/src/packages/BUILD/kernel-default-3.4.24.25/linux-3.4/lib/prio_tree.c:280!
[...]
Process: grep (pid: 64867, threadinfo: ffff880005010000, task: ffff8800022d5c80) on CPU: 2
Pid: 64867, comm: grep
RIP: 0010:[<ffffffff812259c9>]  [<ffffffff812259c9>] prio_tree_remove+0xe9/0xf0
RSP: 0018:ffff880005011d00 EFLAGS: 00010283
RAX: ffff880001eb6650 RBX: ffff880001eb6650 RCX: ffff88013d0ecb38
RDX: ffff88013d0ecb00 RSI: ffff880001eb6650 RDI: ffff88013d0ecb38
RBP: ffff880005011d38 R08: 2222222222222222 R09: 2222222222222222
R10: 0000000000000000 R11: 0000000000000000 R12: ffff88013d0ecb38
R13: ffff880001eb6650 R14: ffff88013d0ecb00 R15: ffff880001eb6600
FS: 00007f366dd35700(0000) GS:ffff88016d840000(0000) knlGS:0000000000000000
CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000402008 CR3: 000000000ac65000 CR4: 00000000001607f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Call Trace:
 [<ffffffff8110476b>] vma_prio_tree_remove+0x9b/0x130
 [<ffffffff81114efb>] __remove_shared_vm_struct.isra.27+0x3b/0x60
 [<ffffffff811153f9>] unlink_file_vma+0x49/0x70
 [<ffffffff8110e5f1>] free_pgtables+0x41/0x120
 [<ffffffff81115102>] unmap_region+0xe2/0x140
 [<ffffffff811163b6>] do_munmap+0x2f6/0x3d0
 [<ffffffff811164dc>] vm_munmap+0x4c/0x70
 [<ffffffff81117bc6>] sys_munmap+0x26/0x40
 [<ffffffff81467965>] system_call_fastpath+0x16/0x1b

we have checked the vmcore, and find the vma was added to a prio tree which is no
belong to its present vma->vm_file->f_mapping->i_mmap, but I do not know how this
could happen, any clue about this?

I know maybe it is not suitable to discuss a problem for this old kernel here, but
do hope to get some help from some more specialist. Thanks for any of comment.

Thanks
Yisheng

The more detail steps I debug as following:
crash> dis -l prio_tree_remove
[...]
and find r13 is node, rbx is the cur, (r13 is the same as rbx, so cur is the same as node)
for cur we get its vma:

crash> struct -x vm_area_struct 0xffff880001eb6600
struct vm_area_struct {
  vm_mm = 0xffff880004f04400,
  vm_start = 0x7f366dd37000,
  vm_end = 0x7f366dd3d000,
  vm_next = 0x0,
  vm_prev = 0x0,
  vm_page_prot = {
    pgprot = 0x8000000000000025
  },
  vm_flags = 0x8000071,
  vm_rb = {
    rb_parent_color = 0xffff880001eb7d79,
    rb_right = 0x0,
    rb_left = 0xffff880001eb73b8
  },
  shared = {
    vm_set = {
      list = {
        next = 0xffff880001eb6650,
        prev = 0xffff880001eb6650
      },
      parent = 0xffff880001eb6650,
      head = 0xffff8800096da000
    },
    prio_tree_node = {
      left = 0xffff880001eb6650,
      right = 0xffff880001eb6650,
      parent = 0xffff880001eb6650
    }
  },
  anon_vma_chain = {
    next = 0xffff880001eb6670,
    prev = 0xffff880001eb6670
  },
  anon_vma = 0x0,
  vm_ops = 0xffffffff81614640,
  vm_pgoff = 0x0,
  vm_file = 0xffff880036c5c700,
  vm_private_data = 0x0,
  vm_policy = 0x0,
  euler_kabi_padding = {0x0, 0x0}
}

then file and dentry:
crash> struct -x file 0xffff880036c5c700
struct file {
  f_u = {
    fu_list_deprecated = {
      next = 0x0,
      prev = 0x0
    },
    fu_rcuhead = {
      next = 0x0,
      func = 0
    }
  },
  f_path = {
    mnt = 0xffff8801550b82a0,
    dentry = 0xffff88013f531368
  },
  f_op = 0xffffffff81614480,
  f_lock = {
    {
      rlock = {
        raw_lock = {
          {
            head_tail = 0x0,
            tickets = {
              head = 0x0,
              tail = 0x0
            }
          }
        },
        magic = 0xdead4ead,
        owner_cpu = 0xffffffff,
        owner = 0xffffffffffffffff
      }
    }
  },
  f_sb_list_cpu_deprecated = 0x0,
  f_count = {
    counter = 0x4
  },
  f_flags = 0x8000,
  f_mode = 0x1d,
  f_pos = 0x340,
  f_owner = {
    lock = {
      raw_lock = {
        lock = 0x100000,
        write = 0x100000
      },
      magic = 0xdeaf1eed,
      owner_cpu = 0xffffffff,
      owner = 0xffffffffffffffff
    },
    pid = 0x0,
    pid_type = PIDTYPE_PID,
    uid = 0x0,
    euid = 0x0,
    signum = 0x0
  },
  f_cred = 0xffff88000ac2ccc0,
  f_ra = {
    start = 0x0,
    size = 0x0,
    async_size = 0x0,
    ra_pages = 0x0,
    mmap_miss = 0x0,
    prev_pos = 0xffffffffffffffff
  },
  f_version = 0x0,
  f_security = 0x0,
  private_data = 0x0,
  f_ep_links = {
    next = 0xffff880036c5c7d0,
    prev = 0xffff880036c5c7d0
  },
  f_tfile_llink = {
    next = 0xffff880036c5c7e0,
    prev = 0xffff880036c5c7e0
  },
  f_mapping = 0xffff88013d0ecb00
}

crash> struct -x dentry 0xffff88013f531368
struct dentry {
  d_flags = 0x88,
  d_seq = {
    sequence = 0x4
  },
  d_hash = {
    next = 0x0,
    pprev = 0xffffc9000233bec8
  },
  d_parent = 0xffff88013f573e60,
  d_name = {
    hash = 0x67491608,
    len = 0xe,
    name = 0xffff88013f5313a0 "libc-2.11.3.so"
  },
  d_inode = 0xffff88013d0ec980,
  d_iname = "libc-2.11.3.so\000lect_nvram.sh\000\000\000",
  d_count = 0x4f,
  d_lock = {
    {
      rlock = {
        raw_lock = {
          {
            head_tail = 0x7878,
            tickets = {
              head = 0x78,
              tail = 0x78
            }
          }
        },
        magic = 0xdead4ead,
        owner_cpu = 0xffffffff,
        owner = 0xffffffffffffffff
      }
    }
  },
  d_op = 0xffffffff81618f80,
  d_sb = 0xffff88016d411800,
  d_time = 0x0,
  d_fsdata = 0x0,
  d_lru = {
    next = 0xffff88013f531400,
    prev = 0xffff88013f531400
  },
  d_child = {
    next = 0xffff88013f525c80,
    prev = 0xffff88013f524f00
  },
  d_subdirs = {
    next = 0xffff88013f531420,
    prev = 0xffff88013f531420
  },
  d_u = {
    d_alias = {
      next = 0xffff88013d0ecac8,
      prev = 0xffff88013d0ecac8
    },
    d_rcu = {
      next = 0xffff88013d0ecac8,
      func = 0xffff88013d0ecac8
    }
  }
}


ok, go back to vma itself find it has head, and the head is another vma: 0xffff8800096da000;
crash> struct -x vm_area_struct 0xffff8800096da000
struct vm_area_struct {
  vm_mm = 0xffff880073fbbc00,
  vm_start = 0x7f555fc20000,
  vm_end = 0x7f555fc26000,
  vm_next = 0xffff8800096dba40,
  vm_prev = 0xffff8800096dacc0,
  vm_page_prot = {
    pgprot = 0x8000000000000025
  },
  vm_flags = 0x8000071,
  vm_rb = {
    rb_parent_color = 0xffff8800096dba78,
    rb_right = 0x0,
    rb_left = 0x0
  },
  shared = {
    vm_set = {
      list = {
        next = 0xffff880002477910,
        prev = 0xffff88002499cc50
      },
      parent = 0x0,
      head = 0xffff880001eb6600
    },
    prio_tree_node = {
      left = 0xffff880002477910,
      right = 0xffff88002499cc50,
      parent = 0x0
    }
  },
  anon_vma_chain = {
    next = 0xffff8800096da070,
    prev = 0xffff8800096da070
  },
  anon_vma = 0x0,
  vm_ops = 0xffffffff81614640,
  vm_pgoff = 0x0,
  vm_file = 0xffff880039facb00,
  vm_private_data = 0x0,
  vm_policy = 0x0,
  euler_kabi_padding = {0x0, 0x0}
}

Then file and dentry:

crash> struct -x file 0xffff880039facb00
struct file {
  f_u = {
    fu_list_deprecated = {
      next = 0x0,
      prev = 0x0
    },
    fu_rcuhead = {
      next = 0x0,
      func = 0
    }
  },
  f_path = {
    mnt = 0xffff8801550b82a0,
    dentry = 0xffff880056495290
  },
  f_op = 0xffffffff81614480,
  f_lock = {
    {
      rlock = {
        raw_lock = {
          {
            head_tail = 0x0,
            tickets = {
              head = 0x0,
              tail = 0x0
            }
          }
        },
        magic = 0xdead4ead,
        owner_cpu = 0xffffffff,
        owner = 0xffffffffffffffff
      }
    }
  },
  f_sb_list_cpu_deprecated = 0x0,
  f_count = {
    counter = 0x1
  },
  f_flags = 0x8000,
  f_mode = 0x1d,
  f_pos = 0x0,
  f_owner = {
    lock = {
      raw_lock = {
        lock = 0x100000,
        write = 0x100000
      },
      magic = 0xdeaf1eed,
      owner_cpu = 0xffffffff,
      owner = 0xffffffffffffffff
    },
    pid = 0x0,
    pid_type = PIDTYPE_PID,
    uid = 0x0,
    euid = 0x0,
    signum = 0x0
  },
  f_cred = 0xffff880002477980,
  f_ra = {
    start = 0x0,
    size = 0x0,
    async_size = 0x0,
    ra_pages = 0x0,
    mmap_miss = 0x0,
    prev_pos = 0xffffffffffffffff
  },
  f_version = 0x0,
  f_security = 0x0,
  private_data = 0x0,
  f_ep_links = {
    next = 0xffff880039facbd0,
    prev = 0xffff880039facbd0
  },
  f_tfile_llink = {
    next = 0xffff880039facbe0,
    prev = 0xffff880039facbe0
  },
  f_mapping = 0xffff88013d235b90               ----> oh, no the same address_space
}

Check this address_space:
crash> struct -x address_space 0xffff88013d235b90
struct address_space {
  host = 0xffff88013d235a10,
  page_tree = {
    height = 0x1,
    gfp_mask = 0x20,
    rnode = 0xffff88011b9ff599
  },
  tree_lock = {
    {
      rlock = {
        raw_lock = {
          {
            head_tail = 0x2a2a,
            tickets = {
              head = 0x2a,
              tail = 0x2a
            }
          }
        },
        magic = 0xdead4ead,
        owner_cpu = 0xffffffff,
        owner = 0xffffffffffffffff
      }
    }
  },
  i_mmap_writable = 0x0,
  i_mmap = {
    prio_tree_node = 0xffff880001eb6650,     -----> this is rbx(cur and also the node)
    index_bits = 0x3,
    raw = 0x1
  },
  i_mmap_nonlinear = {
    next = 0xffff88013d235bd8,
    prev = 0xffff88013d235bd8
  },
  i_mmap_mutex = {
    count = {
      counter = 0x1
    },
    wait_lock = {
      {
        rlock = {
          raw_lock = {
            {
              head_tail = 0x8f8f,
              tickets = {
                head = 0x8f,
                tail = 0x8f
              }
            }
          },
          magic = 0xdead4ead,
          owner_cpu = 0xffffffff,
          owner = 0xffffffffffffffff
        }
      }
    },
    wait_list = {
      next = 0xffff88013d235c08,
      prev = 0xffff88013d235c08
    },
    owner = 0xffff88004cfec560,
    name = 0x0,
    magic = 0xffff88013d235be8
  },
  nrpages = 0x6,
  writeback_index = 0x0,
  a_ops = 0xffffffff81614240,
  flags = 0x200da,
  backing_dev_info = 0xffffffff818890e0,
  private_lock = {
    {
      rlock = {
        raw_lock = {
          {
            head_tail = 0x0,
            tickets = {
              head = 0x0,
              tail = 0x0
            }
          }
        },
        magic = 0xdead4ead,
        owner_cpu = 0xffffffff,
        owner = 0xffffffffffffffff
      }
    }
  },
  private_list = {
    next = 0xffff88013d235c70,
    prev = 0xffff88013d235c70
  },
  assoc_mapping = 0x0
}
crash> struct dentry -x 0xffff880056495290
struct dentry {
  d_flags = 0x88,
  d_seq = {
    sequence = 0x8
  },
  d_hash = {
    next = 0x0,
    pprev = 0xffffc900000bf508
  },
  d_parent = 0xffff88013f79e288,
  d_name = {
    hash = 0x7983921a,
    len = 0xb,
    name = 0xffff8800564952c8 "ld.so.cache"
  },
  d_inode = 0xffff88013d235a10,
  d_iname = "ld.so.cache\000\000e\000l\000ournal\000\020SIV\000\210\377\377",
  d_count = 0x5,
  d_lock = {
    {
      rlock = {
        raw_lock = {
          {
            head_tail = 0x3232,
            tickets = {
              head = 0x32,
              tail = 0x32
            }
          }
        },
        magic = 0xdead4ead,
        owner_cpu = 0xffffffff,
        owner = 0xffffffffffffffff
      }
    }
  },
  d_op = 0xffffffff81618f80,
  d_sb = 0xffff88016d411800,
  d_time = 0x0,
  d_fsdata = 0x0,
  d_lru = {
    next = 0xffff880056495328,
    prev = 0xffff880056495328
  },
  d_child = {
    next = 0xffff88010e91d770,
    prev = 0xffff8800584ae408
  },
  d_subdirs = {
    next = 0xffff880056495348,
    prev = 0xffff880056495348
  },
  d_u = {
    d_alias = {
      next = 0xffff88013d235b58,
      prev = 0xffff88013d235b58
    },
    d_rcu = {
      next = 0xffff88013d235b58,
      func = 0xffff88013d235b58
    }
