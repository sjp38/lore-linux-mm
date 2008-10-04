Received: by ug-out-1314.google.com with SMTP id p35so1336070ugc.19
        for <linux-mm@kvack.org>; Sat, 04 Oct 2008 15:11:03 -0700 (PDT)
Date: Sun, 5 Oct 2008 02:13:39 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 2/2] Report the pagesize backing a VMA in /proc/pid/maps
Message-ID: <20081004221339.GA20175@x200.localdomain>
References: <1223052415-18956-1-git-send-email-mel@csn.ul.ie> <1223052415-18956-3-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1223052415-18956-3-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, dave@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 03, 2008 at 05:46:55PM +0100, Mel Gorman wrote:
> This patch adds a new field for hugepage-backed memory regions to show the
> pagesize in /proc/pid/maps.  While the information is available in smaps,
> maps is more human-readable and does not incur the cost of calculating Pss. An
> example of a /proc/self/maps output for an application using hugepages with
> this patch applied is;
> 
> 08048000-0804c000 r-xp 00000000 03:01 49135      /bin/cat
> 0804c000-0804d000 rw-p 00003000 03:01 49135      /bin/cat
> 08400000-08800000 rw-p 00000000 00:10 4055       /mnt/libhugetlbfs.tmp.QzPPTJ (deleted) (hpagesize=4096kB)

> To be predictable for parsers, the patch adds the notion of reporting on VMA
> attributes by appending one or more fields that look like "(attribute)". This
> already happens when a file is deleted and the user sees (deleted) after the
> filename. The expectation is that existing parsers will not break as those
> that read the filename should be reading forward after the inode number
> and stopping when it sees something that is not part of the filename.
> Parsers that assume everything after / is a filename will get confused by
> (hpagesize=XkB) but are already broken due to (deleted).

Looks like procps will start showing hpagesize tag as a mapping name
(apologies for pasting crappy code):



static const char *mapping_name(proc_t *p, unsigned KLONG addr, unsigned KLONG len, const char *mapbuf, unsigned showpath, unsigned dev_major, unsigned dev_minor, unsigned long long inode){
  const char *cp;

  if(!dev_major && dev_minor==shm_minor && strstr(mapbuf,"/SYSV")){
    static char shmbuf[64];
    snprintf(shmbuf, sizeof shmbuf, "  [ shmid=0x%Lx ]", inode);
    return shmbuf;
  }

  cp = strrchr(mapbuf,'/');
  if(cp){
    if(showpath) return strchr(mapbuf,'/');
    return cp[1] ? cp+1 : cp;
  }

  cp = strchr(mapbuf,'/');
  if(cp){
    if(showpath) return cp;
    return strrchr(cp,'/') + 1;  // it WILL succeed
  }

  cp = "  [ anon ]";
  if( (p->start_stack >= addr) && (p->start_stack <= addr+len) )  cp = "  [ stack ]";
  return cp;
}

static int one_proc(proc_t *p){

	...

  while(fgets(mapbuf,sizeof mapbuf,stdin)){

	...

    if(x_option){
      const char *cp = mapping_name(p, start, diff, mapbuf, 0, dev_major, dev_minor, inode);
      printf(
        (sizeof(KLONG)==8)
          ? "%016"KLF"x %7lu       -       -       - %s  %s\n"
          :      "%08lx %7lu       -       -       - %s  %s\n",
        start,
        (unsigned long)(diff>>10),
        flags,
        cp
      );
    }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
