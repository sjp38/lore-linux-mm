Subject: mapping large amount of memory on physical addresses
Message-ID: <OF16513350.814DBFED-ONC1256FBE.00590893@brime.fr>
From: scarayol@assystembrime.com
Date: Tue, 8 Mar 2005 17:15:25 +0100
MIME-Version: 1.0
Content-type: text/plain; charset=iso-8859-1
Content-transfer-encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

Could you help me : I work on embedded Linux on a MPC885 processor
(PowerPC).

In the user space, I want to map 2 differents types of memory (with
separate components) to make data transferts between each others. So, i
want to affect each memory with their physical adress in the memory map
with the mmap instruction. It's the only way I found to affect the good
memory area to the physical component. Do you know another way ?

I mapped about 1 MB for a MC Memory and 1MB for DV memory. In my last code,
the size are shorter. For that, I reserved high Ram addresses by the use of
'mem=6M' (in u-boot) to reserve 2MB for my memories.
The successive mmap succeed but when I test the memory area with successive
writing and reading, several differents things appear : the program seems
blocked or it creates a kernel panic.
-> Why can it create a kernel panic though the memory is essentially out of
the kernel area and I allocate few memory ? And what's could happen ?
-> In the mapped zones, I realize that I can't use the first eight bytes
(writing doesn't work) : why ?

In the final application, MC will have a size of 2MB and DV a size of about
36MB. Is there any problem of mapping on physical addresses such a size of
36MB, is there any restrictions with the mmap instruction?
What the maximum size of allocating with malloc in user space, can i
allocate 36MB in a contiguous manner ?

You can see my code below. It works but only if secteur <= 2 and when I
increase this number, the problems begin. What is it wrong ?

Thank you really for your help.

Best regards.

----------------------------------------------------------
Sophie CARAYOL

Tel: +33 2 98 10 30 06
mailto:scarayol@assystembrime.com
----------------------------------------------------------

#define MEM_FILE "/dev/mem"
define MC_START 0x600000
#define MC_SIZE 0xFF000
#define DV_START 0x700000
#define DV_SIZE 0x200000

/* ---------------------------------------  MC memory
-----------------------------------------  */
   // mapping of MC
   // opening file descriptor associated with MC
   if ((MC_fd = open(MEM_FILE,O_RDWR | O_SYNC))<0)
   {
        perror("Opening file descriptor MC");
         return false;
   }

   pmyMC= (SecteurMC * )mmap((void *) MC_START, (size_t) MC_SIZE, PROT_READ
| PROT_WRITE, MAP_SHARED | MAP_FIXED, MC_fd, 0);

   if (pmapMC == MAP_FAILED)
   {
        printf("Erreur de mmap pour MC:%s\n", strerror(errno));
         close(MC_fd);
         return false;
     }

   /* --------------------------------------- DV memory
---------------------------------------------- */
   // mapping of DV
   // opening file descriptor associated with DV
   if ((DV_fd = open(MEM_FILE,O_RDWR | O_SYNC))<0)
   {
        perror("Opening file descriptor DV");
         return false;
   }
   pmyDV = (Disque * )mmap((void *) DV_START, (size_t) DV_SIZE, PROT_READ |
PROT_WRITE, MAP_SHARED | MAP_FIXED, DV_fd, 0);
   if (pmyDV == MAP_FAILED)
   {
        printf("Erreur de mmap pour DV:%s\n", strerror(errno));
         close(DV_fd);
         return false;
   }

memory_mapped = 1;


   // test de la memoire MC
   for (secteur = 0; secteur < 2; secteur++)
   {
       test_memory_MC(0xAA, secteur);
   }
   printf("--- Memoire MC OK ---\n");

   // test de la memoire DV
   for (secteur = 0; secteur < 2; secteur++)
   {
      test_memory_DV(0x55, 0, secteur);
   }
   printf("--- Memoire DV OK ---\n");

   release_memory();

/*******************************************************************************************************/

bool test_memory_MC(u8 value,u16 num_secteur)
{
#define OFFSET_MC 0
#define NB_OCTET MAX_MOT*sizeof(u16)
   int i, piste, secteur;
   u8 pb = false;
   u16 TMot[MAX_MOT], value_MC;
   u16 * pTab;

   if (memory_mapped)
   {
      /* ------------------------------ test de MC
---------------------------------------------*/
      pTab = (u16 *)malloc(NB_OCTET);
      pTab = (u16 *)pmyMC;
      pTab += num_secteur*MAX_MOT;
      printf("pTab : %8X, OFFSET_MC = %i\n",pTab, OFFSET_MC);
      // ecriture
      memset(pTab, value,MAX_MOT*sizeof(u16));

      // reading
      memcpy(TMot,pTab,MAX_MOT*sizeof(u16));
      value_MC = ((u16)value << 8) + value;

      // comparing reading / writing
      for (i = 0 + OFFSET_MC; i < MAX_MOT; i++)
      {
         if (TMot[i] != value_MC)
         {
          printf("Pb MC !!i = %i, adr =%8X, TMot =  %X\n",i,pTab+i ,
TMot[i]);
          pb = true;

         }
      }
      if (pb == true)
      {
            return false;
      }
   } /* if (memory_mapped) */

   return true;
} // fin de test_memory_MC()
/*
************************************************************************
*  Function  :  test_memory_DV
************************************************************************
*  Purpose   :  test de la memoire DV mappee
*  Restrictions:  a virer au final
*
************************************************************************
*  Parameters  :
*          IN  : value
*
*          OUT : aucun
*
*
************************************************************************
*/
bool test_memory_DV(u8 value, u8 piste, u16 secteur)
{
#define OFFSET_DV 0
#define NB_OCTET MAX_MOT*sizeof(u16)

   int i;
   u8 pb = false;
   u16 TMot[MAX_MOT], value_DV;
   u16 * pTab;

   if (memory_mapped)
   {
       /* ------------------------------ test de DV
---------------------------------------------*/
       pTab = (u16 *)malloc(NB_OCTET);
       pTab = (u16 *)pmyDV;

       pTab += (piste*MAX_SECTEUR + secteur)*MAX_MOT;
       printf(" sur piste =%i, secteur =%i - pmyDV: %8X\n",piste,
secteur,pTab);

       // writing
       memset(pTab, value,MAX_MOT*sizeof(u16));

       value_DV = ((u16)value << 8) + value;

       // reading and comparing
       memcpy(TMot,pTab,NB_OCTET);
       for (i = 0 + OFFSET_DV; i < MAX_MOT; i++)
       {
          if (TMot[i] != value_DV)
          {
           printf("Pb DV !!i = %i, adr =%8X, TMot =  %X\n",i,pTab+i ,
TMot[i]);
           pb = true;
          }
       }
       if (pb == true)
       {
            return false;
       }

  } /* if (memory_mapped) */

  return true;
} // fin de test_memory_DV()


/*
************************************************************************
*  Function  :  release_memory
************************************************************************
*  Purpose   :  Liberation des memoires mappees
*  Restrictions:
*
************************************************************************
*  Parameters  :
*          IN  : aucun
*
*          OUT : aucun
*
*
************************************************************************
*/
void release_memory(void)
{
   if (memory_mapped)
   {
       munmap((void*)MC_START,(size_t) MC_SIZE);
       munmap((void*)DV_START,(size_t) DV_SIZE);

       close(MC_fd);
       close(DV_fd);

       memory_mapped = 0;
   }

   return;
} // fin de release_memory()



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
