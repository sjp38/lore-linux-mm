Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 57F796B01F4
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 06:03:44 -0400 (EDT)
Received: by ey-out-1920.google.com with SMTP id 5so45479eyb.18
        for <linux-mm@kvack.org>; Mon, 26 Apr 2010 03:03:41 -0700 (PDT)
Date: Mon, 26 Apr 2010 12:03:05 +0200
From: Dan Carpenter <error27@gmail.com>
Subject: smatch warning in mm/mmap.c
Message-ID: <20100426100305.GP29093@bicker>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: riel@redhat.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Rik,

This code generates a Smatch warning.  I normally ignore Smatch warnings
in mm because I'm not clever enough to mess with that, but this one is
pretty recent so I thought I'd ask.  Could you take a look?

mm/mmap.c +1980 __split_vma(57) error: we previously assumed 'new->vm_ops' could be null.
  1966          if (new->vm_ops && new->vm_ops->open)
                    ^^^^^^^^^^^
	We assume new->vm_ops can be NULL here.

  1967                  new->vm_ops->open(new);
  1968
  1969          if (new_below)
  1970                  err = vma_adjust(vma, addr, vma->vm_end, vma->vm_pgoff +
  1971                          ((addr - new->vm_start) >> PAGE_SHIFT), new);
  1972          else
  1973                  err = vma_adjust(vma, vma->vm_start, addr, vma->vm_pgoff, new);
  1974
  1975          /* Success. */
  1976          if (!err)
  1977                  return 0;
  1978
  1979          /* Clean everything up if vma_adjust failed. */
  1980          new->vm_ops->close(new);
                ^^^^^^^^^^^^^^^^^^

	But we dereference it unconditionally here.  

The dereference was added in 5beb4930: "mm: change anon_vma linking to fix
multi-process server scalability issue".

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
