Received: from [192.168.1.190] ([192.168.1.190])
	by arianne.in.ishoni.com (8.11.6/Ishonir2) with ESMTP id gAI84UU29173
	for <linux-mm@kvack.org>; Mon, 18 Nov 2002 13:34:30 +0530
Subject: mincore_vma function
From: Amol Kumar Lad <amolk@ishoni.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 18 Nov 2002 13:30:29 -0500
Message-Id: <1037644230.10326.57.camel@amol.in.ishoni.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
  I'm bit confused while reading this function

static long mincore_vma(struct vm_area_struct * vma,
        unsigned long start, unsigned long end, unsigned char * vec)
{
        long error, i, remaining;
        unsigned char * tmp;

        error = -ENOMEM;
        if (!vma->vm_file)
                return error;

        start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
        if (end > vma->vm_end)
                end = vma->vm_end;
        end = ((end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;

        error = -EAGAIN;
        tmp = (unsigned char *) __get_free_page(GFP_KERNEL);
        if (!tmp)
                return error;

        /* (end - start) is # of pages, and also # of bytes in "vec */
        remaining = (end - start),

        error = 0;
        for (i = 0; remaining > 0; remaining -= PAGE_SIZE, i++) {
                int j = 0;
                long thispiece = (remaining < PAGE_SIZE) ?
                                                remaining : PAGE_SIZE;
>>>> Why this check ? Is it possible the remaining is not a multiple of
page (remaining = end - start)

                while (j < thispiece)
                        tmp[j++] = mincore_page(vma, start++);
>>>> why this loop ?? Don't we only need to call mincore_page _once_
with second arg start += PAGE_SIZE; 

                if (copy_to_user(vec + PAGE_SIZE * i, tmp, thispiece)) {
                        error = -EFAULT;
                        break;
                }
>>>> Again, accroding to man page of mincore, each byte of vec tells
whether page is resident or not... What is above copy_to_user doing
        }

        free_page((unsigned long) tmp);
        return error;
}

I am using 2.4.57-mm2

-- Amol


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
